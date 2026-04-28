enum CountryCode {
  ph('Philippines', '🇵🇭', '+63'),
  us('United States', '🇺🇸', '+1'),
  sg('Singapore', '🇸🇬', '+65'),
  au('Australia', '🇦🇺', '+61'),
  gb('United Kingdom', '🇬🇧', '+44'),
  jp('Japan', '🇯🇵', '+81'),
  kr('South Korea', '🇰🇷', '+82'),
  hk('Hong Kong', '🇭🇰', '+852'),
  ca('Canada', '🇨🇦', '+1');

  const CountryCode(this.name, this.flag, this.dialCode);

  final String name;
  final String flag;
  final String dialCode;
}
