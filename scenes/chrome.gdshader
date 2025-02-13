shader_type spatial;

// Properties for customizing the chrome effect
uniform vec4 base_color : source_color = vec4(0.8, 0.8, 0.8, 1.0);
uniform float metallic : hint_range(0.0, 1.0) = 1.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.1;
uniform float specular : hint_range(0.0, 1.0) = 0.5;
uniform sampler2D reflection_map : hint_default_white;
uniform vec2 uv_scale = vec2(1.0, 1.0);

// Fresnel effect parameters
uniform float fresnel_power : hint_range(0.0, 10.0) = 5.0;
uniform float fresnel_intensity : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    // Base metallic properties
    METALLIC = metallic;
    ROUGHNESS = roughness;
    SPECULAR = specular;
    
    // Calculate view direction in world space
    vec3 view_dir = normalize(VIEW);
    vec3 normal = normalize(NORMAL);
    
    // Calculate fresnel effect
    float fresnel = pow(1.0 - dot(normal, view_dir), fresnel_power);
    
    // Sample reflection map with scaled UVs
    vec2 reflected_uv = UV * uv_scale;
    vec4 reflection = texture(reflection_map, reflected_uv);
    
    // Combine base color with reflection and fresnel
    vec4 final_color = mix(base_color, reflection, fresnel * fresnel_intensity);
    
    // Apply final color
    ALBEDO = final_color.rgb;
    
    // Add some rim lighting
    RIM = 0.2;
    RIM_TINT = 0.5;
}

void light() {
    // Enhanced specular reflection
    float spec = pow(max(dot(reflect(-LIGHT, NORMAL), VIEW), 0.0), 32.0);
    SPECULAR_LIGHT += spec * LIGHT_COLOR * specular;
    
    // Calculate diffuse lighting
    float ndotl = dot(NORMAL, LIGHT);
    DIFFUSE_LIGHT += max(ndotl, 0.0) * LIGHT_COLOR * ALBEDO;
}