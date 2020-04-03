class Note {
  int cases;
  String country;
  int deaths;
  int recovered;
  int critical;
  Map<String, dynamic> image;
  
  Note(this.country, this.cases, this.deaths, this.recovered, this.critical, this.image);

  Note.fromJson(Map<String, dynamic> json) {
    country = json['country'];
    cases = json['cases'];
    deaths = json['deaths'];
    recovered = json['recovered'];
    critical = json['critical'];
    image = json['countryInfo'];
  }
}