// NOTE: Shader automatically converted from Godot Engine 4.6.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_nearest, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

uniform sampler2D texture_heightmap : source_color, filter_linear, repeat_disable;
uniform sampler2D texture_ground : source_color, filter_linear_mipmap, repeat_disable;
uniform sampler2D texture_rock : source_color, filter_linear_mipmap, repeat_disable;

uniform sampler2D rock_normal : source_color, filter_linear_mipmap, repeat_disable;
uniform sampler2D rock_roughness : source_color, filter_linear_mipmap, repeat_disable;
uniform sampler2D displacement : source_color, filter_linear, repeat_disable;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform int width = 512;
uniform int height = 512;

uniform vec4 color_bottom : source_color;
uniform vec4 color_top : source_color;
uniform vec4 color_cutoff_bottom : source_color;
uniform vec4 color_cutoff_top : source_color;

uniform float color_cutoff_height_bottom = 1.9;
uniform float color_cutoff_height_top = 2.0;
uniform float max_vertical_height = 5.0;
uniform sampler2D dig_texture : source_color, filter_linear, repeat_enable;
uniform float data_bottom_threshold : hint_range(-1.0, 1.0) = 0.0;
uniform float data_top_threshold : hint_range(0.0, 1.0) = 1.0;

varying float vertex_height;
varying vec3 vertex_color;
uniform bool grow;
varying float rock_ratio;
varying float rock_threshold;


float random (vec2 uv) {
    return fract(sin(dot(uv,
        vec2(12.9898,78.233))) * 43758.5453123);
}

float sample_heightmap(sampler2D tex, vec2 uv) {
	float pixel_size = 0.5 / float(width);
	vec4 color = texture(tex, uv);
	return (color.r + color.g + color.b + color.a) / 4.0;
}

float lower_ratio(float position_x, float position_z, vec2 uv) {
	if (mod(position_x, 1.0) < 0.1 && mod(position_z, 1.0) < 0.1) {
		return texture(dig_texture, uv).r;
	}
	return (
		texture(dig_texture, vec2((position_x - 0.5) / float(width), (position_z - 0.5) / float(height))).r
		+ texture(dig_texture, vec2((position_x + 0.5) / float(width), (position_z - 0.5) / float(height))).r
		+ texture(dig_texture, vec2((position_x + 0.5) / float(width), (position_z + 0.5) / float(height))).r
		+ texture(dig_texture, vec2((position_x - 0.5) / float(width), (position_z + 0.5) / float(height))).r
	) / 4.0;
}

float lerp(float a, float b, float ratio) {
	float diff = b - a;
	return a + (diff * clamp(ratio, 0.0, 1.0));
}

float remap_data_height(float data_height) {
	data_height -= data_bottom_threshold;
	return clamp(data_height / (data_top_threshold - data_bottom_threshold), 0.0, 1.0);
}

vec3 get_vertex_position(float position_x, float position_z) {
	float v_height;
	vec2 uv = vec2(position_x / float(width), position_z / float(height));
	
	v_height = lerp(remap_data_height(sample_heightmap(texture_heightmap, uv)) + random(vec2(position_x, position_z)) * 0.002, 0.0, lower_ratio(position_x, position_z, uv));
	
	return vec3(position_x, v_height, position_z);
}

vec3 triangle_normal(vec3 a, vec3 b, vec3 c) {
	vec3 normal = vec3(
		a.y * b.z - a.z * b.y,
		a.z * b.x - a.x * b.z,
		a.x * b.y - a.y * b.x
	);
	return normal / sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z);
}

vec3 calculate_normal(vec3 position) {
	vec3 normal = (
		//triangle_normal(
			//get_vertex_position(position.x - 1.0, position.z - 1.0) * vec3(1.0, max_vertical_height, 1.0),
			//get_vertex_position(position.x + 1.0, position.z - 1.0) * vec3(1.0, max_vertical_height, 1.0),
			//get_vertex_position(position.x - 1.0, position.z + 1.0) * vec3(1.0, max_vertical_height, 1.0)
		//)
		- triangle_normal(
			get_vertex_position(position.x + 1.5, position.z - 1.5) * vec3(1.0, max_vertical_height, 1.0),
			get_vertex_position(position.x - 1.5, position.z + 1.5) * vec3(1.0, max_vertical_height, 1.0),
			get_vertex_position(position.x + 1.5, position.z + 1.5) * vec3(1.0, max_vertical_height, 1.0)
		)
	);
	return normal / sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z);
}

void vertex() {
	vec3 vertex_world_position = NODE_POSITION_WORLD + VERTEX;
	vec3 vertex_position = get_vertex_position(vertex_world_position.x, vertex_world_position.z);
	
	vertex_height = vertex_position.y;
	
	float vertex_physical_height = vertex_height * max_vertical_height;
	VERTEX.y = vertex_physical_height;

	if (vertex_physical_height < color_cutoff_height_bottom) {
		vertex_color = color_bottom.rgb + (color_cutoff_bottom.rgb - color_bottom.rgb) * (vertex_physical_height / color_cutoff_height_bottom);
	} else if (vertex_physical_height < color_cutoff_height_top) {
		vertex_color = color_cutoff_bottom.rgb + (color_cutoff_top.rgb - color_cutoff_bottom.rgb) * ((vertex_physical_height - color_cutoff_height_bottom) / (color_cutoff_height_top - color_cutoff_height_bottom));
	} else {
		vertex_color = color_cutoff_top.rgb + (color_top.rgb - color_cutoff_top.rgb) * ((vertex_physical_height - color_cutoff_height_top) / (max_vertical_height - color_cutoff_height_top));
	}
	
	NORMAL = calculate_normal(vertex_world_position);
	
	UV = vertex_world_position.xz * uv1_scale.xy + uv1_offset.xy;
	rock_threshold = 0.15 + sin((vertex_world_position.x + vertex_world_position.z) * 0.6) * 0.01;
	
	if (NORMAL.y > 0.7) {
		rock_ratio = 0.0;
	} else {
		rock_ratio = 1.0;
	}
	
	if (grow) {
		VERTEX += NORMAL;
	}
}

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = vertex_color * albedo_tex.rgb;
	
	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	
	if (vertex_height < 0.002) {
		ALBEDO = mix(texture(texture_ground, vec2(mod(base_uv.x, 1.0), mod(base_uv.y, 1.0))).rgb, ALBEDO, clamp(vertex_height, 0.0, 0.002) * 500.0);
	} else if (vertex_height > rock_threshold) {
		float mix_ratio = lerp(0.0, rock_ratio, clamp((vertex_height - rock_threshold) * 50.0, 0.0, 1.0));
		ALBEDO = mix(ALBEDO, texture(texture_rock, vec2(mod(base_uv.x / 2.0, 1.0), mod(base_uv.y / 2.0, 1.0))).rgb, mix_ratio);
		float rock_roughness_here = dot(texture(rock_roughness, base_uv / 2.0), roughness_texture_channel);
		roughness_tex = mix(roughness_tex, rock_roughness_here, mix_ratio);
		NORMAL = NORMAL * mix(vec3(1.0, 1.0, 1.0), texture(rock_normal, base_uv / 2.0).rgb, mix_ratio);
	}

	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	ROUGHNESS = roughness_tex * roughness;
}
