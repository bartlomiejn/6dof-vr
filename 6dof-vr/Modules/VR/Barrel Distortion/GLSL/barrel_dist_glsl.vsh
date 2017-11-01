attribute vec4 vertex_pos;
varying vec2 vertex_uv;

void main() {
    gl_Position = vertex_pos;
    vertex_uv = vertex_pos.xy;
}
