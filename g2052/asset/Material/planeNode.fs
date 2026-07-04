#version 100

uniform sampler2D texSampler;
uniform sampler2D texSamplerMask;

varying mediump vec4 color;
varying mediump vec2 texCoord;

void main(void)
{

    mediump vec4 textureColor = texture2D(texSampler, texCoord);
    mediump vec4 textureColorMask = texture2D(texSamplerMask, texCoord);
    textureColor.a *= textureColorMask.a;
    if (textureColor.a < 0.3)
    {
        discard;
    }

	gl_FragColor = textureColor;
}