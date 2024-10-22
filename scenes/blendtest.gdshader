shader_type canvas_item;

void fragment() {
    // Get the color of the object
    vec4 color = texture(TEXTURE, UV);
    
    // Set the blending mode by modifying the alpha and RGB channels
    vec4 blend_color = vec4(color.rgb * color.a, color.a);
    
    // Output the blended color
    COLOR = blend_color;
}