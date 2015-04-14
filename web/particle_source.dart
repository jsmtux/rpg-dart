library particle_source;

import 'dart:math' as math;

import 'package:vector_math/vector_math.dart';

import 'drawable.dart';
import 'renderer.dart';

class Particle
{
  Vector3 position_;
  Vector3 acceleration_;
  ParticleSource source_;
  
  Particle(this.position_, this.acceleration_, this.source_);
  
  void update()
  {
    position_ += acceleration_;
    acceleration_ += source_.gravity_;
  }
}

class ParticleSource
{
  Drawable texture_;
  List<Particle> particles_;
  Vector3 position_;
  Vector3 gravity_;
  bool finished_;
  int total_iters_;
  int iter_;
  
  ParticleSource(this.position_, this.gravity_, this.texture_, this.total_iters_, int num_particles_)
  {
    finished_ = false;
    iter_ = 0;
    math.Random rand = new math.Random();
    for(int i = 0; i < num_particles_; i++)
    {
      double angle = rand.nextDouble() * 360;
      Vector3 accel = new Vector3(math.cos(angle), math.sin(angle), 0.0);
      particles_.add(new Particle(position_, accel, this));
    }
  }
  
  void update()
  {
    if (!finished_)
    {
      iter_++;
      finished_ = iter_ > total_iters_;
      for (Particle p in particles_)
      {
        p.update();
      }
    }
  }
  
  void draw(Renderer renderer)
  {
    if (!finished_)
    {
      for(Particle p in particles_)
      {
        Vector3 pos = p.position_ + position_;
        texture_.setPosition(pos);
        renderer.renderElement(texture_);
      }
    }
  }
}