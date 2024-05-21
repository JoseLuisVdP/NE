shader_type spatial;

varying vec3 worldPos;

group_uniforms Soil;
	uniform vec4 green : source_color;
	uniform vec4 brown : source_color;
	uniform vec4 snow : source_color;
	uniform vec4 grass : source_color;

uniform sampler2D grassTexture;


void vertex() {
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec4 finalColor = green;
	vec3 up = vec3(0,1,0);
	vec3 normal = (vec4(NORMAL,1.0) * VIEW_MATRIX).xyz;
	float dotProd = dot(normal, up);
	vec4 grassPatches = clamp(texture(grassTexture, worldPos.xz/10000.0).rgba * grass * grass.a, 0.6, 1);

	finalColor = smoothstep(0.7, 1, dotProd) * green / grassPatches + smoothstep(1, 0.2, dotProd) * brown + smoothstep(0.95, 1, dotProd) * snow * snow.a;

	finalColor = finalColor;

	/*
	if (dotProd < 0.9) {
		finalColor = brown;
	} else {
		finalColor = green;
	}*/
    ALBEDO = finalColor.rgb;
}