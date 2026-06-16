public class CountryCodeHelper {
    public static string getCountryCode(String country) {
      return Country_Code__mdt.getInstance(country).Country_Code__c;
    }
  }