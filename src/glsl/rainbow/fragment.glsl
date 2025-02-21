uniform float time;
uniform sampler2D camTex;
uniform sampler2D faceHighlightsTex;
varying vec2 vVideoUv;
varying vec2 vUv;

uniform float gridAmount;
uniform float gridAmountX;
uniform float gridAmountY;
uniform bool gridWaveAutomaticFrequency;
uniform float gridWaveFrequency; 
uniform float gridWaveFrequencySpeed;
uniform bool gridWaveExtreme;

#define PI 3.1415926535897932384626433832795

// void main()	{
//     // vec2 uv = gl_FragCoord.xy/RENDERSIZE.xy;
//     vec2 uv = vVideoUv;
    
//     vec4 color = texture2D(camTex, vVideoUv);

//     vec3 color1 = 0.5 + 0.5 * cos(time + uv.xyx + vec3(0, 2, 4));

//     gl_FragColor = vec4(color.rgb * color1, color.a);
// }

vec2 fade(vec2 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}

float cnoise(vec2 P){
  vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
  vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
  Pi = mod(Pi, 289.0); // To avoid truncation effects in permutation
  vec4 ix = Pi.xzxz;
  vec4 iy = Pi.yyww;
  vec4 fx = Pf.xzxz;
  vec4 fy = Pf.yyww;
  vec4 i = permute(permute(ix) + iy);
  vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
  vec4 gy = abs(gx) - 0.5;
  vec4 tx = floor(gx + 0.5);
  gx = gx - tx;
  vec2 g00 = vec2(gx.x,gy.x);
  vec2 g10 = vec2(gx.y,gy.y);
  vec2 g01 = vec2(gx.z,gy.z);
  vec2 g11 = vec2(gx.w,gy.w);
  vec4 norm = 1.79284291400159 - 0.85373472095314 * 
    vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
  g00 *= norm.x;
  g01 *= norm.y;
  g10 *= norm.z;
  g11 *= norm.w;
  float n00 = dot(g00, vec2(fx.x, fy.x));
  float n10 = dot(g10, vec2(fx.y, fy.y));
  float n01 = dot(g01, vec2(fx.z, fy.z));
  float n11 = dot(g11, vec2(fx.w, fy.w));
  vec2 fade_xy = fade(Pf.xy);
  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
  float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}

void main()	{
	vec2 uv = vUv;
    vec4 color = texture2D(camTex, vVideoUv);

    // We use this texture to get soft edges of face
    vec3 edgeColor = texture2D(faceHighlightsTex, vUv).rgb;

	float gridx = mod(uv.x * gridAmount, gridAmountX);
	float gridy = mod(uv.y * gridAmount, gridAmountY);
	float _gridWaveFrequency = gridWaveFrequency;
	
	if (gridWaveAutomaticFrequency) {
	    _gridWaveFrequency = time;
	}
	
	_gridWaveFrequency *= gridWaveFrequencySpeed;
	
	float noise1 = (gridx + gridy) * cnoise(uv.xy) + _gridWaveFrequency;
    float noise2 = cnoise(vec2(gridx, gridy)) + _gridWaveFrequency;

	vec3 color1 = vec3(cnoise(vec2(noise1, uv.x)), cnoise(vec2(noise1, uv.y)), cnoise(vec2(uv.y, noise1)));
	
	if (gridWaveExtreme) {
	    color1 -= cnoise(vec2(noise1, noise2));
	}

    // color /= vec4(color1, .4);

    color.rgb = mix(color1.rgb, color.rgb, vec3(.6));

    color.rgb += mix(color1.rgb, edgeColor, vec3(.2));

    gl_FragColor = vec4(color.rgb, color.a);
}







