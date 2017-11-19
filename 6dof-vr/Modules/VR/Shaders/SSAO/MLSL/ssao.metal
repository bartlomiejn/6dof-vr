//
//  ssao.metal
//  6dof-vr
//
//  Created by Bartłomiej Nowak on 03/11/2017.
//  Copyright © 2017 Bartłomiej Nowak. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

struct VertexInput {
    float4 position [[attribute(SCNVertexSemanticPosition)]];
};

struct VertexOutput {
    float4 position [[position]];
    float2 uv;
};

constexpr sampler tex_sampler(coord::normalized, address::clamp_to_edge, filter::linear);

vertex VertexOutput
passthrough(VertexInput in_vert [[stage_in]]) {
    VertexOutput out_vert;
    
    out_vert.position = in_vert.position;
    out_vert.uv = float2(in_vert.position.x, -in_vert.position.y);
    
    return out_vert;
}

fragment half4
screen_space_ambient_occlusion(VertexOutput in_vert [[stage_in]],
                               texture2d<float, access::sample> color_texture [[texture(0)]],
                               texture2d<float, access::sample> depth_texture [[texture(1)]]) {

    return half4(color_texture.sample(tex_sampler, uv));
}
