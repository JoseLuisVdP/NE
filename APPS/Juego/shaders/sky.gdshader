shader_type sky;

uniform vec3 skyColor : source_color;
uniform vec3 horizonColor : source_color;

uniform sampler2D cloudTexture1;
uniform sampler2D cloudTexture2;

group_uniforms sun; // First DirectionalLight3D will be the sun
	uniform vec3 sun_color : source_color = vec3( 10.0, 8.0, 1.0 );
	uniform vec3 sun_sunset_color : source_color = vec3( 10.0, 0.0, 0.0 );
	uniform float sun_size : hint_range( 0.01, 1.0 ) = 0.2;
	uniform float sun_blur : hint_range( 0.01, 20.0 ) = 10.0;

group_uniforms moon; // Second DirectionalLight3D will be the moon
	uniform vec3 moon_color : source_color = vec3( 1.0, 0.95, 0.7 );
	uniform float moon_size : hint_range( 0.01, 1.0 ) = 0.06;
	uniform float moon_blur : hint_range( 0.01, 10.0 ) = 0.1;

group_uniforms clouds;
	uniform vec2 cloudDir_1;
	uniform vec2 cloudDir_2;
	uniform vec2 cloudScale;
	uniform float cloudDistance;
	uniform float cloudSpeed1;
	uniform float cloudSpeed2;
	uniform float distantCloudiness;
	uniform float height;
	uniform float CloudDarkness;

void sky() {
	float cloudDarkness = CloudDarkness;

	vec2 skyUV = EYEDIR.xz / EYEDIR.y * height;
	vec3 clouds = texture(cloudTexture1, skyUV * cloudScale + TIME * cloudDir_1*cloudSpeed1).rgb - texture(cloudTexture2, skyUV * cloudScale + TIME * cloudDir_2*cloudSpeed2).rgb;
	clouds = clouds - pow(smoothstep(0.0, EYEDIR.y, cloudDistance), distantCloudiness);
	clouds = clamp(clouds, -0.25, 1);

	float col = clamp(EYEDIR.y/0.05, 0.0, 1.0);

	if (cloudDarkness < 1.0) {
		cloudDarkness = 1.0;
	}

	vec3 finalColor = mix(horizonColor, skyColor + clouds, col)* (1.0/cloudDarkness);
	float angle = sin(LIGHT0_DIRECTION.g);
	float redAngle;
	if (LIGHT0_DIRECTION.g > radians(0.0) && LIGHT0_DIRECTION.g < radians(18.0)) {
		redAngle = sin(LIGHT0_DIRECTION.g * 10.0);
	}
	else {
		redAngle = 0.0;
	}
	float intensity = max(min(angle * 1.25, 1), 0);
	vec3 timeColor = vec3((LIGHT0_DIRECTION.g * 2.5), 0.3, 1) * (redAngle/5.0);

	COLOR = (finalColor * (LIGHT0_ENERGY * intensity) + timeColor);
}

	// Called for every visible pixel in the sky background, as well as all pixels
	// in the radiance cubemap.
	// Color para atardecer/amanecer: COLOR = vec3(EYEDIR.y/skyColor);

	// Dibujar el sol
	/*vec3 sunPos = LIGHT0_DIRECTION * 1000.0;
	float radius = 10.0;

	if (abs(length(FRAGCOORD.xyz - sunPos)) < radius) {
		finalColor = vec3(0,0,0);
	}*/