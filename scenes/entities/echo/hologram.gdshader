shader_type spatial;

uniform sampler2D depth_texture : hint_depth_texture;
uniform vec3 primary_color : source_color = vec3(1.0, 0.0, 0.0);
uniform vec3 secondary_color : source_color = vec3(1.0, 0.0, 0.0);

//https://godotshaders.com/shader/vertex-mesh-rotator/

mat3 rotateX(float theta)
{
	
	float cosa = cos(theta);
	float sina = sin(theta);

 
    //Y rotation	
	mat3 rotate_x  = mat3(
	   vec3(1.0, 0.0, 0.0),
	   vec3(0.0, cosa, -sina),
	   vec3(0.0, sina, cosa)
	);
	
	return rotate_x;
}





mat3 rotateY(float theta)
{
	
	float cosa = cos(theta);
	float sina = sin(theta);

 
    //Y rotation	
	mat3 rotate_y  = mat3(
	   vec3(cosa, 0.0, sina),
	   vec3(0.0, 1.0, 0.0),
	   vec3(-sina, 0.0, cosa)
	);
	
	return rotate_y;
}



mat3 rotateZ(float theta)
{
	
	float cosa = cos(theta);
	float sina = sin(theta);

 
    //Y rotation	
	mat3 rotate_z  = mat3(
	   vec3(cosa,-sina, 0.0),
	   vec3(sina, cosa, 0.0),
	   vec3(0.0, 0.0, 1.0)
	);
	
	return rotate_z;
}


void vertex()
{

	mat3 rotation_matrix =  rotateX(float(INSTANCE_ID) * 5.8 + TIME * 0.5) * rotateY(float(INSTANCE_ID) * 3.4+ TIME * 0.5) * rotateZ(float(INSTANCE_ID) * 1.3 + TIME * 0.5);
	vec3 rotated_vertex =  rotation_matrix * VERTEX;
	vec3 rotated_normals =  rotation_matrix * NORMAL;

	VERTEX =  rotated_vertex;
	NORMAL =  rotated_normals;
	

}

void fragment() {
	ALBEDO = secondary_color;
	EMISSION = secondary_color * 20.0;
}