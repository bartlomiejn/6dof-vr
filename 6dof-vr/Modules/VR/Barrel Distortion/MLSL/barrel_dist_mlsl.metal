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

// MARK: - Vertex Passthrough

struct VertexInput {
    float4 position [[attribute(SCNVertexSemanticPosition)]];
};

struct VertexOutput {
    float4 position [[position]];
    float2 uv;
};

vertex VertexOutput passthrough(VertexInput vert [[stage_in]]) {
    VertexOutput output_vert;
    output_vert.position = vert.position;
    output_vert.uv = float2((vert.position.x + 1.0) * 0.5, (-vert.position.y + 1.0) * 0.5);
    return output_vert;
}

// MARK: - Barrel Distortion

constexpr sampler s = sampler(coord::normalized, address::clamp_to_edge, filter::linear);

fragment half4 barrel_dist(VertexOutput vert [[stage_in]],
                           texture2d<float, access::sample> color_sampler [[texture(0)]]) {
    float4 fragment_color = color_sampler.sample(s, vert.uv);
    return half4(fragment_color);
}
