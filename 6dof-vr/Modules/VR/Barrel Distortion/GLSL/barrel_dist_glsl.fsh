
const float PI = 3.1415926535;

uniform sampler2D color_sampler;
varying vec2 vertex_uv;

void main() {
    float aperture = 188.0;
    float partial_aperture = 0.5 * aperture * (PI / 180.0);
    float max_factor = sin(partial_aperture);
    
    vec2 uv;
    vec2 xy = vertex_uv.xy;
    
    float d = length(xy);
    if (d < (2.0 - max_factor)) {
        d = length(xy * max_factor);
        float z = sqrt(1.0 - d * d);
        float r = atan(d, z) / PI;
        float phi = atan(xy.y, xy.x);
        
        uv.x = r * cos(phi) + 0.5;
        uv.y = r * sin(phi) + 0.5;
    } else {
        uv = vertex_uv.xy;
    }

    gl_FragColor = texture2D(color_sampler, uv);
}
