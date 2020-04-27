class State {

  Map<String, dynamic> _state_map;

  State() {
    this._state_map = {};
  }

  dynamic getLocal(String key) {
    return this._state_map[key];
  }

  bool hasLocal(String key) {
    return this._state_map.containsKey(key);
  }

  void putLocal(String key, local) {
    this._state_map[key] = local; 
  }

  void forEach(void action(String key, local)) {
    this._state_map.forEach(action);
  }
  
}
