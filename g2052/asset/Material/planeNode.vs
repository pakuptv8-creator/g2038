#version 100

attribute vec4 inPosition;
attribute vec2 inTexCoord;
attribute vec4 inColor;

uniform mat4 matWVP;


varying vec4 color;
varying vec2 texCoord;

void main(void)
{
	color = inColor;
	texCoord = vec2(inTexCoord);
    gl_Position = matWVP * vec4(inPosition);
}