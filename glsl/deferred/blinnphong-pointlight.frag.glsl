#version 100
precision highp float;
precision highp int;

#define NUM_GBUFFERS 4

uniform vec3 u_lightCol;
uniform vec3 u_lightPos;
uniform vec3 u_cameraPos;

uniform float u_lightRad;
uniform sampler2D u_gbufs[NUM_GBUFFERS];
uniform sampler2D u_depth;


varying vec2 v_uv;

vec3 applyNormalMap(vec3 geomnor, vec3 normap) {
    normap = normap * 2.0 - 1.0;
    vec3 up = normalize(vec3(0.001, 1, 0.001));
    vec3 surftan = normalize(cross(geomnor, up));
    vec3 surfbinor = cross(geomnor, surftan);
    return normap.y * surftan + normap.x * surfbinor + normap.z * geomnor;
}


//https://en.wikipedia.org/wiki/Blinn%E2%80%93Phong_shading_model

void main() {
    vec4 gb0 = texture2D(u_gbufs[0], v_uv); // albedo
    vec4 gb1 = texture2D(u_gbufs[1], v_uv); // position
    vec4 gb2 = texture2D(u_gbufs[2], v_uv); // surface normal
    vec4 gb3 = texture2D(u_gbufs[3], v_uv); // geom normal

    vec3 pos = gb1.xyz;     // World-space position
    vec3 geomnor = gb3.xyz;  // Normals of the geometry as defined, without normal mapping
    vec3 colmap = gb0.xyz;  // The color map - unlit "albedo" (surface color)
    vec3 normap = gb2.xyz;  // The raw normal map (normals relative to the surface they're on)

    float depth = texture2D(u_depth, v_uv).x;
    
    // If nothing was rendered to this pixel, set alpha to 0 so that the
    // postprocessing step can render the sky color.
    if (depth == 1.0) {
        gl_FragColor = vec4(0, 0, 0, 0);
        return;
    }

    vec3 lightDir = normalize(u_lightPos - pos);
    vec3 normal = applyNormalMap(geomnor, normap);


    float lambertian = max(dot(lightDir, normal), 0.0);
    float specular = 0.0;

    if (lambertian > 0.0) {
        vec3 viewDir = normalize(u_cameraPos - pos);

        //blinn phong
        vec3 halfDir = normalize(lightDir + viewDir);
        float specAngle = max(dot(normal, halfDir), 0.0);
        //specular = pow(specAngle, 4.0);
    }

    vec3 color = (lambertian + specular) * u_lightCol * vec3(1.0);
    float attenuation = max(0.0, u_lightRad - distance(u_lightPos, pos));

    gl_FragColor = vec4(color * attenuation, 1);  
}
