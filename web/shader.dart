library Shader;

import 'dart:web_gl' as webgl;

import 'shader_properties.dart';

abstract class Shader
{
  webgl.Program shader_program_;
  webgl.RenderingContext gl_;
  List<ShaderProperty> shader_properties_ = new List<ShaderProperty>();

  Shader (String vertex_source, String fragment_source, webgl.RenderingContext gl)
  {
    gl_ =  gl;
    webgl.Shader vs = gl.createShader(webgl.RenderingContext.VERTEX_SHADER);
    gl.shaderSource(vs, vertex_source);
    gl.compileShader(vs);

    webgl.Shader fs = gl.createShader(webgl.RenderingContext.FRAGMENT_SHADER);
    gl.shaderSource(fs, fragment_source);
    gl.compileShader(fs);

    shader_program_ = gl.createProgram();
    gl.attachShader(shader_program_, vs);
    gl.attachShader(shader_program_, fs);
    gl.linkProgram(shader_program_);
    gl.useProgram(shader_program_);

    if (!gl.getShaderParameter(vs, webgl.RenderingContext.COMPILE_STATUS)) {
      print(gl.getShaderInfoLog(vs));
    }

    if (!gl.getShaderParameter(fs, webgl.RenderingContext.COMPILE_STATUS)) {
      print(gl.getShaderInfoLog(fs));
    }

    if (!gl.getProgramParameter(shader_program_, webgl.RenderingContext.LINK_STATUS)) {
      print(gl.getProgramInfoLog(shader_program_));
    }
  }

  void initProperties()
  {
    for (ShaderProperty prop in shader_properties_)
    {
      prop.init(gl_, shader_program_);
    }
  }

  void makeCurrent()
  {
    gl_.useProgram(shader_program_);
    for (ShaderProperty prop in shader_properties_)
    {
      prop.update(gl_);
    }
  }

  ShaderProperty getShaderProperty(String name)
  {
    ShaderProperty ret;

    for (ShaderProperty prop in shader_properties_)
    {
      if (prop.getName() == name)
      {
        ret = prop;
        break;
      }
    }

    return ret;
  }
}

class BasicShader extends Shader
{
  BasicShaderProperties basic_properties_ = new BasicShaderProperties();

  BasicShader(String vertex_source, String fragment_source, webgl.RenderingContext gl) : super(vertex_source, fragment_source, gl)
  {
    shader_properties_.add(basic_properties_);
    initProperties();
  }
}

String color_vs_source = """
attribute vec3 aVertexPosition;
attribute vec4 aVertexColor;

uniform mat4 uMVMatrix;
uniform mat4 uWVMatrix;
uniform mat4 uPMatrix;

varying vec4 vColor;

void main(void) {
  gl_Position = uPMatrix * uWVMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
  vColor = aVertexColor;
}
""";

String color_fs_source = """
precision mediump float;
varying vec4 vColor;
void main(void) {
  gl_FragColor = vColor;
}
    """;

Shader createColorShader(webgl.RenderingContext gl) => new BasicShader(color_vs_source, color_fs_source, gl);

String texture_vs_source = """
attribute vec3 aVertexPosition;
attribute vec2 aTextureCoord;

uniform mat4 uMVMatrix;
uniform mat4 uWVMatrix;
uniform mat4 uPMatrix;

varying vec2 vTextureCoord;

void main(void) {
  gl_Position = uPMatrix * uWVMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
  vTextureCoord = aTextureCoord;
}
""";

String texture_fs_source = """
precision mediump float;
varying vec2 vTextureCoord;
uniform sampler2D uSampler;
void main(void) {
  gl_FragColor = texture2D(uSampler, vec2(vTextureCoord.s, vTextureCoord.t));
}
""";

Shader createTextureShader(webgl.RenderingContext gl) => new BasicShader(texture_vs_source, texture_fs_source, gl);

String texture_part_vs_source = """
precision mediump float;

attribute vec3 aVertexPosition;
attribute vec2 aTextureCoord;

uniform mat4 uMVMatrix;
uniform mat4 uWVMatrix;
uniform mat4 uPMatrix;

uniform vec2 t_offset;
uniform vec2 t_size;
varying vec2 vTextureCoord;

void main(void) {
  gl_Position = uPMatrix * uWVMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
  vTextureCoord = aTextureCoord * t_size + t_offset;
}
""";

String texture_part_fs_source = """
precision mediump float;
varying vec2 vTextureCoord;

uniform sampler2D uSampler;
void main(void) {
  gl_FragColor = texture2D(uSampler, vec2(vTextureCoord.s, vTextureCoord.t));
}
""";

class AtlasShader extends Shader
{
  BasicShaderProperties basic_properties_ = new BasicShaderProperties();
  AtlasTextureProperty atlas_property_ = new AtlasTextureProperty();

  AtlasShader(String vertex_source, String fragment_source, webgl.RenderingContext gl) : super(vertex_source, fragment_source, gl)
  {
    shader_properties_.add(basic_properties_);
    shader_properties_.add(atlas_property_);
    initProperties();
  }
}

Shader createAtlasShader(webgl.RenderingContext gl) => new AtlasShader(texture_part_vs_source, texture_part_fs_source, gl);


String lighting_vs_source = """
precision mediump float;

const int MAX_POINT_LIGHTS = 2;

attribute vec3 aVertexPosition;
attribute vec3 aVertexNormal;
attribute vec2 aTextureCoord;

uniform mat4 uMVMatrix;
uniform mat4 uWVMatrix;
uniform mat4 uPMatrix;
uniform mat3 uNMatrix;

uniform vec3 uAmbientColor;

uniform vec3 uDirectionalDir;
uniform vec3 uDirectionalColor;

struct PointLight
{
  vec3 uPos;
  vec3 uColor;
  vec3 uAttenuation;
};

uniform PointLight lights[MAX_POINT_LIGHTS];

varying vec2 vTextureCoord;
varying vec3 vLightWeighting;
varying vec3 vVertexPos;

vec3 calcLightInternal(vec3 vertex_normal, vec3 light_dir, vec3 color)
{
  vec3 trans_normal = uNMatrix * vertex_normal;
  float lightWeighting = max(dot(trans_normal, normalize(light_dir)), 0.0);
  return color * lightWeighting;
}

vec3 calcDirLight(vec3 vertex_normal)
{
  return calcLightInternal(vertex_normal, uDirectionalDir, uDirectionalColor);
}

vec3 calcPointLight(vec3 vertex_normal, vec3 vertex_pos, int index)
{
  vec3 light_dir = lights[index].uPos - vertex_pos;
  float distance = length(light_dir);
  return calcLightInternal(vertex_normal, light_dir, lights[index].uColor) / distance * lights[index].uAttenuation.x;  
}

void main(void) {
  gl_Position = uPMatrix * uWVMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);

  vTextureCoord = aTextureCoord;

  vec3 vertex_pos = (uMVMatrix * vec4(aVertexPosition, 1.0)).xyz;

  vLightWeighting = uAmbientColor + calcDirLight(aVertexNormal) + calcPointLight(aVertexNormal, vertex_pos, 0);
}
""";

String lighting_fs_source = """
precision mediump float;
varying vec2 vTextureCoord;
varying vec3 vLightWeighting;
varying vec3 vVertexPos;
uniform sampler2D uSampler;

void main(void) {
  vec4 texture_color = texture2D(uSampler, vec2(vTextureCoord.s, vTextureCoord.t));
  gl_FragColor = vec4(texture_color.xyz * vLightWeighting, texture_color.a);
}
""";

class LightShader extends Shader
{
  BasicShaderProperties basic_properties_ = new BasicShaderProperties();
  LightingShaderProperty light_property_ = new LightingShaderProperty();

  LightShader(String vertex_source, String fragment_source, webgl.RenderingContext gl)
    : super(vertex_source, fragment_source, gl)
  {
    shader_properties_.add(basic_properties_);
    shader_properties_.add(light_property_);
    initProperties();
  }
}

Shader createLightShader(webgl.RenderingContext gl) => new LightShader(lighting_vs_source, lighting_fs_source, gl);
