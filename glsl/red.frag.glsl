#version 100
precision highp float;
precision highp int;

#pragma name scissor_debug_white
void main() {
    gl_FragColor = vec4(0.1, 0.1, 0.1, 0.1);
}
