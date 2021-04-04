#pragma glslify: import('../../glsl/common.glsl')

attribute vec2 videoUv;

varying vec2 vUv;
varying vec2 vVideoUv;

void main() {
  vUv = uv;
  vVideoUv = videoUv;

  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.);
}