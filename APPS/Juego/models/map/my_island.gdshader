shader_type spatial;

varying vec3 worldPos;
uniform sampler2D noise;
uniform float noiseScale = 2000.0;

group_uniforms Soil;
	uniform vec4 green : source_color;
	uniform vec4 brown : source_color;
	uniform vec4 snow : source_color;
	uniform vec4 grass : source_color;

void vertex() {
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec4 finalColor = green;
	vec3 up = vec3(0,1,0);
	vec3 normal = (vec4(NORMAL,1.0) * VIEW_MATRIX).xyz;
	float dotProd = dot(normal, up);
	
	vec3 noiseLevel = texture(noise, abs(worldPos.xz) / noiseScale).rgb;
	
	vec4 g = mix(green, grass, noiseLevel.r);
	g = smoothstep(0.6, 1, dotProd) * g;
	vec4 br = dotProd * brown;
	//vec4 s = smoothstep(0.95, 1, dotProd) * snow;
	
	finalColor = mix(g, br, 0.5);

	/*
	if (dotProd < 0.9) {
		finalColor = brown;
	} else {
		finalColor = green;
	}*/
    ALBEDO = finalColor.rgb;
}