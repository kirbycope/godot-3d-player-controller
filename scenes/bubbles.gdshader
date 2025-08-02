/*
	バブルシェーダー by あるる（きのもと 結衣） @arlez80
	Bubble Shader by Yui Kinomoto @arlez80

	MIT License
*/

shader_type spatial;

uniform float fuwafuwa_speed = 1.5;
uniform float fuwafuwa_size = 0.05;

uniform vec4 outline_color = vec4( 0.45, 0.70, 1.0, 1.0 );
uniform float outline_ratio = 1.0;
uniform float noise_speed = 0.2;
uniform float noise_scale = 0.5;

vec3 hsv2rgb( float h, float s, float v )
{
	return (
		(
			clamp(
				abs( fract( h + vec3( 0.0, 2.0, 1.0 ) / 3.0 ) * 6.0 - 3.0 ) - 1.0
			,	0.0
			,	1.0
			) - 1.0
		) * s + 1.0
	) * v;
}

float random( vec2 pos )
{ 
	return fract(sin(dot(pos, vec2(12.9898,78.233))) * 43758.5453);
}

void vertex( )
{
	vec3 v = clamp( cos( VERTEX * 10.0 + vec3( TIME * fuwafuwa_speed ) ) + vec3( 1.0 ), 0.0, 1.0 );
	VERTEX *= 1.0 + dot( v, v ) * fuwafuwa_size * 0.5;
}

void fragment( )
{
	float outline_alpha = clamp( ( 1.0 - dot( NORMAL, VIEW ) ) * outline_ratio, 0.0, 1.0 );
	vec3 color = hsv2rgb( outline_alpha - 1.5 + noise_speed * TIME, 1.0, 1.0 ) * noise_scale;

	ALBEDO = mix( color, outline_color.rgb, max( outline_alpha - 0.3, 0.0 ) );
	ALPHA = outline_color.a * outline_alpha;
}
