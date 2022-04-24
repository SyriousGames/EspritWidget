part of flint_particles;

typedef InitializeFn = void Function(Emitter emitter, Particle particle);

/// Initializes the particle dynamically using [initializeFn].
class InitFn extends InitializerBase {
  InitializeFn initializeFn;

  InitFn(this.initializeFn);

  @override
  void initialize(Emitter emitter, Particle particle) {
    initializeFn(emitter, particle);
  }
}
