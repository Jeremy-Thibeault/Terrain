shader_type spatial;

instance uniform float height = 0.0;
uniform sampler2D normal_map;
uniform sampler2D gradient;
uniform sampler2D noise;

varying vec3 albedo;


float get_height(vec3 world_vertex){
	vec2 chunk_offset = (world_vertex.xz) / float(textureSize(noise, 0).x);
	return (texture(noise, chunk_offset).r * height) - (height * 0.5);
}

vec3 get_color(vec3 world_vertex){
	vec2 chunk_offset = (world_vertex.xz)/float(textureSize(noise,0).x);
	return texture(noise, chunk_offset).rgb;
}

void vertex() {
	vec3 world_vertex = VERTEX + MODEL_MATRIX[3].xyz;
	VERTEX.y = get_height(world_vertex);
}

void fragment() {
	vec4 world_vertex = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	vec3 model_vertex = (inverse(MODEL_MATRIX) * world_vertex).xyz;

	float gradient_uv = (model_vertex.y / height) + 0.5;

	ALBEDO = texture(gradient, vec2(gradient_uv)).rgb;
	NORMAL_MAP = texture(normal_map, UV).xyz;

}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
