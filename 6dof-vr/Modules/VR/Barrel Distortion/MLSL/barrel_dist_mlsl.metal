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
    out_vert.uv = float2((in_vert.position.x + 1.0) * 0.5, (-in_vert.position.y + 1.0) * 0.5);
    
    return out_vert;
}

// MARK: - Fragment - Barrel Distortion

constexpr sampler s = sampler(coord::normalized, address::clamp_to_edge, filter::linear);

fragment half4 barrel_dist(VertexOutput in_vert [[stage_in]],
                           texture2d<float, access::sample> color_sampler [[texture(0)]]) {
    
    float4 fragment_color = color_sampler.sample(s, in_vert.uv);
    return half4(fragment_color);
}
