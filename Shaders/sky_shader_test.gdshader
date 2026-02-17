shader_type sky;
render_mode use_half_res_pass;
uniform sampler2D noise;

float big_noise_offset(float size, vec2 coords, vec2 offset) {
	float bignoise = pow(texture(noise, coords*size + vec2(TIME/750.0)).x, 1.125)/0.3;
	return bignoise;
}

vec4 generate_clouds(vec3 eyedir, vec2 coords) {
	float angle = coords.y;
	float noisepos = pow(angle, 2);
	float noisestat = pow(texture(noise, coords*3.0 - vec2(TIME/600.0)).x, 2.0);
	float noisemob = pow(texture(noise, coords*0.3 + vec2(TIME/1000.0)).x, 0.25)/3.0 - 0.1;
	float skynoise = (noisestat + noisemob - 0.2 - clamp(big_noise_offset(0.03, coords, vec2(0.5, 0.8)), 0, 1)/10.0) / 1.0;
	vec3 nebula = vec3(big_noise_offset(0.01, coords, vec2(0.5, 0.8)),  0.5, big_noise_offset(0.03, coords, vec2(0.2, 0.4)));
	return vec4(nebula + vec3(0.5), pow(skynoise, 1.0));
}

vec3 generate_sky(vec3 eyedir, vec2 coords) {
	vec3 grad = vec3(0.2 - coords.y/5.0);
	return vec3(0, 0, 0.01) - grad/15.0;
}

void sky() {
    if (AT_HALF_RES_PASS) {
        // Run cloud calculation for 1/4 of the pixels
        vec4 color = generate_clouds(EYEDIR, SKY_COORDS);
        COLOR = color.rgb;
        ALPHA = color.a;
    } else {
        // At full resolution pass, blend sky and clouds together
        vec3 color = generate_sky(EYEDIR, SKY_COORDS);
        COLOR = color + HALF_RES_COLOR.rgb * HALF_RES_COLOR.a;
    }
}