part of flint_particles;

/// Marks the particle as dead when its subEmitter is complete (no longer started).
class DeathOnSubEmitterComplete extends ActionBase {
  DeathOnSubEmitterComplete();

  @override
  void update(Emitter emitter, Particle particle, double time) {
    if (particle.subEmitter?.started == false) {
      particle.isDead = true;
    }
  }
}
