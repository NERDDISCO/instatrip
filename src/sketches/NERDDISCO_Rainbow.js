import { EffectPass } from 'postprocessing';

import { Mesh, TextureLoader, ShaderMaterial, Vector3 } from 'three';

import { renderPass, webcamEffect } from '../setup';

import { faceGeometry, metrics } from '../faceMesh';
import { camTextureFlipped } from '../webcam';

import faceHighlightsUrl from '../assets/face_highlights.jpg';

import vert from '../glsl/rainbow/vertex.glsl';
import frag from '../glsl/rainbow/fragment.glsl';

// Define a texture
const faceHighlightsTex = new TextureLoader().load(faceHighlightsUrl);

// Or look into https://github.com/spite/FaceMeshFaceGeometry

export class NerddiscoRainbow {
  constructor({ composer, scene }) {
    // Texture in ThreeJS use it as a mask for ShaderMaterial
    // Alpha = Needs to be set all the time -> https://threejs.org/docs/?q=material#api/en/materials/Material
    this.mat = new ShaderMaterial({
      uniforms: {
        time: { value: 1.0 },
        camTex: { value: camTextureFlipped },
        faceHighlightsTex: { value: faceHighlightsTex },
        masterNormal: { value: new Vector3() },
        baseDisplacement: { value: 0 },
        animatedDisplacementAmp: { value: 50 },
        animatedNormalAmp: { value: 1 },
        gridAmount: { value: 111.63 },
        gridAmountX: { value: 4.8 },
        gridAmountY: { value: 4.8 },
        gridWaveAutomaticFrequency: { value: true },
        gridWaveFrequency: { value: 0.1 },
        gridWaveFrequencySpeed: { value: -0.45 },
        gridWaveExtreme: { value: false },
      },
      // Use a basic vertex
      vertexShader: vert,
      fragmentShader: frag,
    });

    // Add mesh with face as texture
    const mesh = new Mesh(faceGeometry, this.mat);
    scene.add(mesh);

    // Setup all the passes used below
    const camPass = new EffectPass(null, webcamEffect);

    camPass.renderToScreen = true;
    renderPass.renderToScreen = true;
    renderPass.clear = false;

    composer.addPass(camPass);
    composer.addPass(renderPass);
  }

  update({ elapsedS }) {
    this.mat.uniforms.time.value = elapsedS;
    this.mat.uniforms.animatedDisplacementAmp.value = 50 * metrics.zed;
    this.mat.uniforms.masterNormal.value.copy(metrics.track.normal);
  }

  updateParameters({ gridAmount, gridAmountX, gridAmountY, gridWaveAutomaticFrequency, gridWaveFrequency, gridWaveFrequencySpeed, gridWaveExtreme }) {
    this.mat.uniforms.gridAmount.value = gridAmount;
    this.mat.uniforms.gridAmountX.value = gridAmountX;
    this.mat.uniforms.gridAmountY.value = gridAmountY;
    this.mat.uniforms.gridWaveAutomaticFrequency.value = gridWaveAutomaticFrequency;
    this.mat.uniforms.gridWaveFrequency.value = gridWaveFrequency;
    this.mat.uniforms.gridWaveFrequencySpeed.value = gridWaveFrequencySpeed;
    this.mat.uniforms.gridWaveExtreme.value = gridWaveExtreme;
  }
}
