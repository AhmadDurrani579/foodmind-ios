//
//  FoodScanShader.metal
//  FoodMind
//
//  Created by Ahmad on 18/03/2026.
//

#include <metal_stdlib>
using namespace metal;

// ─────────────────────────────────────
// MARK: — Uniforms
// Data passed from Swift to GPU
// ─────────────────────────────────────
struct ScanUniforms {
    float2 boxMin;       // top-left of plate bounding box
    float2 boxMax;       // bottom-right of plate bounding box
    float  confidence;   // 0.0 to 1.0
    float  time;         // seconds since app launch (animation)
    int    hasDetection; // 1 = plate detected, 0 = no plate
};

// ─────────────────────────────────────
// MARK: — Main Shader Function
// Runs on GPU for every pixel
// ─────────────────────────────────────
kernel void foodScanEffect(
    texture2d<float, access::read>  inTexture  [[texture(0)]],  // input frame
    texture2d<float, access::write> outTexture [[texture(1)]],  // output frame
    constant ScanUniforms&          uniforms   [[buffer(0)]],   // our data
    uint2                           gid        [[thread_position_in_grid]] // pixel position
) {
    // ── Read original pixel ───────────
    float4 color = inTexture.read(gid);

    // ── If no detection just pass through ──
    if (uniforms.hasDetection == 0) {
        outTexture.write(color, gid);
        return;
    }

    // ── Normalised UV coords (0.0 to 1.0) ──
    float2 uv = float2(gid) / float2(
        outTexture.get_width(),
        outTexture.get_height()
    );

    float2 boxMin = uniforms.boxMin;
    float2 boxMax = uniforms.boxMax;
    float  conf   = uniforms.confidence;
    float  time   = uniforms.time;

    // ── Glow colour based on confidence ──
    float3 glowColor;
    if (conf >= 0.85) {
        glowColor = float3(0.553, 0.722, 0.478); // FMColors.green
    } else if (conf >= 0.60) {
        glowColor = float3(0.949, 0.788, 0.298); // FMColors.yellow
    } else {
        glowColor = float3(0.910, 0.514, 0.290); // FMColors.orange
    }

    // ── Is pixel inside bounding box ──
    bool insideBox = uv.x > boxMin.x && uv.x < boxMax.x &&
                     uv.y > boxMin.y && uv.y < boxMax.y;

    // ── Border thickness ──────────────
    float borderWidth = 0.005;
    float glowWidth   = 0.030;

    // ── Is pixel on border edge ───────
    bool onBorder =
        insideBox == false && (
        (uv.x > boxMin.x - borderWidth && uv.x < boxMin.x + borderWidth &&
         uv.y > boxMin.y - glowWidth   && uv.y < boxMax.y + glowWidth) ||
        (uv.x > boxMax.x - borderWidth && uv.x < boxMax.x + borderWidth &&
         uv.y > boxMin.y - glowWidth   && uv.y < boxMax.y + glowWidth) ||
        (uv.y > boxMin.y - borderWidth && uv.y < boxMin.y + borderWidth &&
         uv.x > boxMin.x - glowWidth   && uv.x < boxMax.x + glowWidth) ||
        (uv.y > boxMax.y - borderWidth && uv.y < boxMax.y + borderWidth &&
         uv.x > boxMin.x - glowWidth   && uv.x < boxMax.x + glowWidth)
    );

    // ── Is pixel near border (soft glow) ──
    float distToBox = min(
        min(abs(uv.x - boxMin.x), abs(uv.x - boxMax.x)),
        min(abs(uv.y - boxMin.y), abs(uv.y - boxMax.y))
    );
    bool nearBorder = distToBox < glowWidth && !insideBox && !onBorder;

    // ── Pulse animation ───────────────
    float pulse = sin(time * 3.0) * 0.3 + 0.7;

    // ── Scan line (only high confidence) ──
    float scanPos   = fmod(time * 0.4, 1.0);
    bool  isScanLine = conf >= 0.85 &&
                       abs(uv.y - (boxMin.y + scanPos * (boxMax.y - boxMin.y))) < 0.004 &&
                       insideBox;

    // ── Corner accents ────────────────
    float cornerSize = 0.04;
    bool isCorner =
        // Top-left
        ((uv.x > boxMin.x - borderWidth && uv.x < boxMin.x + cornerSize &&
          uv.y > boxMin.y - borderWidth && uv.y < boxMin.y + borderWidth) ||
        (uv.x > boxMin.x - borderWidth  && uv.x < boxMin.x + borderWidth &&
          uv.y > boxMin.y - borderWidth && uv.y < boxMin.y + cornerSize)) ||
        // Top-right
        ((uv.x > boxMax.x - cornerSize  && uv.x < boxMax.x + borderWidth &&
          uv.y > boxMin.y - borderWidth && uv.y < boxMin.y + borderWidth) ||
        (uv.x > boxMax.x - borderWidth  && uv.x < boxMax.x + borderWidth &&
          uv.y > boxMin.y - borderWidth && uv.y < boxMin.y + cornerSize)) ||
        // Bottom-left
        ((uv.x > boxMin.x - borderWidth && uv.x < boxMin.x + cornerSize &&
          uv.y > boxMax.y - borderWidth && uv.y < boxMax.y + borderWidth) ||
        (uv.x > boxMin.x - borderWidth  && uv.x < boxMin.x + borderWidth &&
          uv.y > boxMax.y - cornerSize  && uv.y < boxMax.y + borderWidth)) ||
        // Bottom-right
        ((uv.x > boxMax.x - cornerSize  && uv.x < boxMax.x + borderWidth &&
          uv.y > boxMax.y - borderWidth && uv.y < boxMax.y + borderWidth) ||
        (uv.x > boxMax.x - borderWidth  && uv.x < boxMax.x + borderWidth &&
          uv.y > boxMax.y - cornerSize  && uv.y < boxMax.y + borderWidth));

    // ── Apply effects ─────────────────
    if (isCorner) {
        // Bright corner accents
        color = float4(glowColor, 1.0);

    } else if (onBorder) {
        // Pulsing border
        color = float4(glowColor * pulse, 1.0);

    } else if (isScanLine) {
        // Sweeping scan line
        color = mix(color, float4(glowColor, 1.0), 0.7);

    } else if (nearBorder) {
        // Soft outer glow
        float glowStrength = (1.0 - distToBox / glowWidth) * 0.35 * pulse;
        color = mix(color, float4(glowColor, 1.0), glowStrength);

    } else if (insideBox) {
        // Subtle inside tint
        float tint = 0.05 * pulse;
        color = mix(color, float4(glowColor, 1.0), tint);
    }

    outTexture.write(color, gid);
}

