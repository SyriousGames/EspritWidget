part of flint_particles;

typedef ActionUpdater = void Function(Emitter emitter, Particle particle, double time);

/// Updates the particle dynamically using [actionUpdater].
class ActionFn extends ActionBase {
  ActionUpdater actionUpdater;

  ActionFn(this.actionUpdater);

  @override
  void update(Emitter emitter, Particle particle, double time) {
    this.actionUpdater(emitter, particle, time);
  }
}
