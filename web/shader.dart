library Shader;

import 'dart:math' as Math;
import 'dart:web_gl' as webgl;
import 'dart:typed_data';

import 'package:vector_math/vector_math.dart';

abstract class Shader
{
  webgl.Program shader_program_;
  int a_vertex_pos_;
  int a_vertex_color_;
  int a_vertex_coord_;
  int a_vertex_normal_;
  webgl.UniformLocation u_m_perspective_;
  webgl.UniformLocation u_m_modelview_;
  webgl.UniformLocation u_m_worldview_;

  webgl.RenderingContext gl_;

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

    a_vertex_pos_ = gl.getAttribLocation(shader_program_, "aVertexPosition");
    gl.enableVertexAttribArray(a_vertex_pos_);

    a_vertex_color_ = gl.getAttribLocation(shader_program_, "aVertexColor");
    if (a_vertex_color_ >= 0)
    {
      gl.enableVertexAttribArray(a_vertex_color_);
    }

    a_vertex_normal_ = gl.getAttribLocation(shader_program_, "aVertexNormal");
    if (a_vertex_normal_ >= 0)
    {
      gl.enableVertexAttribArray(a_vertex_normal_);
    }

    a_vertex_coord_ = gl.getAttribLocation(shader_program_, "aTextureCoord");
    if (a_vertex_coord_ >= 0)
    {
      gl.enableVertexAttribArray(a_vertex_coord_);
    }

    u_m_perspective_ = gl.getUniformLocation(shader_program_, "uPMatrix");
    u_m_modelview_ = gl.getUniformLocation(shader_program_, "uMVMatrix");
    u_m_worldview_ = gl.getUniformLocation(shader_program_, "uWVMatrix");
  }

  void setMatrixUniforms(Matrix4 m_perspective_, Matrix4 m_modelview_, Matrix4 m_worldview_)
  {
    Float32List tmpList = new Float32List(16);
    m_perspective_.copyIntoArray(tmpList);
    gl_.uniformMatrix4fv(u_m_perspective_, false, tmpList);

    m_modelview_.copyIntoArray(tmpList);
    gl_.uniformMatrix4fv(u_m_modelview_, false, tmpList);

    m_worldview_.copyIntoArray(tmpList);
    gl_.uniformMatrix4fv(u_m_worldview_, false, tmpList);
  }

  void makeCurrent();
}

class BasicShader extends Shader
{
  BasicShader(String vertex_source, String fragment_source, webgl.RenderingContext gl) : super(vertex_source, fragment_source, gl)
  {
  }

  void makeCurrent()
  {
    gl_.useProgram(shader_program_);
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
  webgl.UniformLocation size_p_;
  webgl.UniformLocation offset_p_;

  Vector2 size_;
  Vector2 offset_;

  AtlasShader(String vertex_source, String fragment_source, webgl.RenderingContext gl) : super(vertex_source, fragment_source, gl)
  {
    size_p_ = gl_.getUniformLocation(shader_program_, "t_size");
    offset_p_ = gl_.getUniformLocation(shader_program_, "t_offset");
  }

  void makeCurrent()
  {
    gl_.useProgram(shader_program_);
    gl_.uniform2f(size_p_, size_.x, size_.y);
    gl_.uniform2f(offset_p_, offset_.x, offset_.y);
  }

  void setOffset(Vector2 offset)
  {
    offset_ = offset;
  }

  void setSize(Vector2 size)
  {
    size_ = size;
  }
}

Shader createAtlasShader(webgl.RenderingContext gl) => new AtlasShader(texture_part_vs_source, texture_part_fs_source, gl);


String terrain_vs_source = """
precision mediump float;
attribute vec3 aVertexPosition;
attribute vec3 aVertexNormal;
attribute vec2 aTextureCoord;

uniform mat4 uMVMatrix;
uniform mat4 uWVMatrix;
uniform mat4 uPMatrix;
uniform mat3 uNMatrix;
uniform vec3 uAmbientLight;
uniform vec3 uLightingDirection;
uniform vec3 uDirectionalColor;

varying vec2 vTextureCoord;
varying vec3 vLightWeighting;

void main(void) {
  gl_Position = uPMatrix * uWVMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
  vTextureCoord = aTextureCoord;
  vec3 trans_normal = uNMatrix * aVertexNormal;
  float directionalLightWeighting = max(dot(trans_normal, uLightingDirection), 0.0);
  vLightWeighting = uAmbientLight + uDirectionalColor * directionalLightWeighting;
}
""";

String terrain_fs_source = """
precision mediump float;
varying vec2 vTextureCoord;
varying vec3 vLightWeighting;
uniform sampler2D uSampler;
void main(void) {
  vec4 texture_color = texture2D(uSampler, vec2(vTextureCoord.s, vTextureCoord.t));
  gl_FragColor = vec4(texture_color.xyz * vLightWeighting, texture_color.a);
}
""";

class TerrainShader extends BasicShader
{
  webgl.UniformLocation u_v3_directional_dir_;
  webgl.UniformLocation u_v3_directional_color_;
  webgl.UniformLocation u_v3_ambient_color_;
  webgl.UniformLocation u_m_normal_;
  Vector3 light_dir_;
  Vector3 ambient_color_ = new Vector3(.0, .0, .0);
  Vector3 directional_color_ = new Vector3(1.0, 1.0, 1.0);
  Vector3 directional_dir_ = new Vector3(0.0, -1.0, 0.0);


  Matrix3 m_normal_ = new Matrix3.identity();

  TerrainShader(String vertex_source, String fragment_source, webgl.RenderingContext gl)
    : super(vertex_source, fragment_source, gl)
  {
    Quaternion directional_rotation = new Quaternion.axisAngle(new Vector3(1.0, 0.0, 0.0), 45.0 * Math.PI / 180);
    directional_rotation.rotate(directional_dir_);
    directional_rotation = new Quaternion.axisAngle(new Vector3(0.0, 1.0, 0.0), 45.0 * Math.PI / 180);
    directional_rotation.rotate(directional_dir_);
    u_v3_directional_color_ = gl.getUniformLocation(shader_program_, "uDirectionalColor");
    u_v3_directional_dir_ = gl.getUniformLocation(shader_program_, "uLightingDirection");
    u_v3_ambient_color_ = gl_.getUniformLocation(shader_program_, "uAmbientLight");
    u_m_normal_ = gl_.getUniformLocation(shader_program_, "uNMatrix");
  }

  void setNormalMatrix(Matrix3 normal_mat)
  {
    m_normal_ = normal_mat;
  }

  void makeCurrent()
  {
    super.makeCurrent();
    gl_.uniform3f(u_v3_ambient_color_, ambient_color_.x, ambient_color_.y, ambient_color_.z);
    gl_.uniform3f(u_v3_directional_color_, directional_color_.x, directional_color_.y, directional_color_.z);
    gl_.uniform3f(u_v3_directional_dir_, directional_dir_.x, directional_dir_.y, directional_dir_.z);
    Float32List tmpList = new Float32List(9);
    m_normal_.copyIntoArray(tmpList);
    gl_.uniformMatrix3fv(u_m_normal_, false, tmpList);
  }
}

Shader createTerrainShader(webgl.RenderingContext gl) => new TerrainShader(terrain_vs_source, terrain_fs_source, gl);
