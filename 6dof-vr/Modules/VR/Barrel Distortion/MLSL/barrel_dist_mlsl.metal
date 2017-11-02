//
//  barrel_dist_mlsl.metal
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 01/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

// MARK: - Vertex - Passthrough

struct VertexInput {
    float4 position [[attribute(SCNVertexSemanticPosition)]];
};

struct VertexOutput {
    float4 position [[position]];
    float2 uv;
};

vertex VertexOutput passthrough(VertexInput in_vert [[stage_in]]) {
    VertexOutput out_vert;
    
    out_vert.position = in_vert.position;
    // Invert 180 degrees and correct viewport position
//    out_vert.uv = float2((in_vert.position.x + 1.0) * 0.5, (-in_vert.position.y + 1.0) * 0.5);
    out_vert.uv = float2(in_vert.position.x, -in_vert.position.y);
    
    return out_vert;
}

// MARK: - Fragment - Barrel Distortion

constexpr sampler s = sampler(coord::normalized, address::clamp_to_edge, filter::linear);

fragment half4 barrel_dist(VertexOutput in_vert [[stage_in]],
                           texture2d<float, access::sample> color_sampler [[texture(0)]]) {
    
    float aperture = 188.0;
    float partial_aperture = 0.5 * aperture * (M_PI_F / 180.0);
    float max_factor = fast::sin(partial_aperture);

    float2 uv;
    float2 xy = float2(in_vert.uv.x, in_vert.uv.y);
    half4 output_color;
    
    float d = fast::length(xy);
    if (d < (2.0 - max_factor)) {
        d = fast::length(xy * max_factor);
        float z = fast::sqrt(1.0 - d * d);
        float r = fast::atan2(d, z) / M_PI_F;
        float phi = fast::atan2(xy.y, xy.x);

        uv.x = r * fast::cos(phi) + 0.5;
        uv.y = r * fast::sin(phi) + 0.5;
        
        output_color = half4(color_sampler.sample(s, uv));
    } else {
        uv = float2(in_vert.uv.x, in_vert.uv.y);
        output_color = half4(0, 0, 0, 0);
    }
    
    return half4(output_color);
}
