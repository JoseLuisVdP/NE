shader_type canvas_item;
render_mode unshaded;

uniform int blurSize : hint_range(0,20);
uniform sampler2D SCREEN_TEXTURE:hint_screen_texture, filter_linear_mipmap;

void fragment()
{
	vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, float(blurSize)* COLOR.a/10.0);
	COLOR = color;
}