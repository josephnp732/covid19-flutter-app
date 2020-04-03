class Global {
  int cases;
  int deaths;
  int recovered;
  int active;
  
  Global(this.cases, this.deaths, this.recovered, this.active);

  Global.fromJson(Map<String, dynamic> json) {
    cases = json['cases'];
    deaths = json['deaths'];
    recovered = json['recovered'];
    active = json['active'];
  }
}