
// Sample WebGL 1 shader. This just outputs a red color
// to indicate WebGL 1 is in use.

#ifdef GL_FRAGMENT_PRECISION_HIGH
#define highmedp highp
#else
#define highmedp mediump
#endif

precision lowp float;

varying mediump vec2 vTex;
uniform lowp sampler2D samplerFront;
uniform mediump vec2 srcStart;
uniform mediump vec2 srcEnd;
uniform mediump vec2 srcOriginStart;
uniform mediump vec2 srcOriginEnd;
uniform mediump vec2 layoutStart;
uniform mediump vec2 layoutEnd;
uniform lowp sampler2D samplerBack;
uniform lowp sampler2D samplerDepth;
uniform mediump vec2 destStart;
uniform mediump vec2 destEnd;
uniform highmedp float seconds;
uniform mediump vec2 pixelSize;
uniform mediump float layerScale;
uniform mediump float layerAngle;
uniform mediump float devicePixelRatio;
uniform mediump float zNear;
uniform mediump float zFar;

//<-- UNIFORMS -->
// uShadowDistance
// uShadowAngle
// uShadowOpacity
// uShadowColor
// uDisplaceExtra

mediump vec4 _sampleBackground(mediump vec2 vTex, mediump vec2 actualWidth2) {
  mediump float radAngle2 = radians(-uShadowAngle);
  mediump vec2 testPoint = vTex + vec2(cos(radAngle2), sin(radAngle2)) * actualWidth2;
  lowp vec4 front = texture2D(samplerFront, testPoint);
  mediump vec2 n = (vTex - srcStart) / (srcEnd - srcStart);
  lowp vec4 back = texture2D(samplerBack, mix(destStart, destEnd, n));
  return vec4(mix(front.rgb, back.rgb, front.a), front.a * back.a);
}

void main(void) {
  mediump float radAngle = radians(180.0 - uShadowAngle);
  mediump vec2 layoutSize = abs(layoutEnd - layoutStart);
  mediump vec2 texelSize = abs(srcOriginEnd - srcOriginStart) / layoutSize;
  mediump vec2 actualWidth = uShadowDistance * texelSize;
  mediump vec2 actualWidth2 = (uShadowDistance + uDisplaceExtra) * texelSize;

  mediump vec4 testPointTex = _sampleBackground(vTex + actualWidth * vec2(cos(radAngle), sin(radAngle)), actualWidth2);
  mediump vec4 tex0 = _sampleBackground(vTex, actualWidth2);
  mediump vec4 color = vec4(uShadowColor.rgb, uShadowOpacity);
  gl_FragColor = mix(mix(tex0, mix(tex0, color, color.a), testPointTex.a), tex0, tex0.a);
}