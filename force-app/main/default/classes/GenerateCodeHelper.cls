public class GenerateCodeHelper {
    public static String generateRandomCode(Integer length) {
        final String CHARACTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        String randCode = '';
        while (randCode.length() < length) {
            Integer idx = Math.floor(Math.random() * CHARACTERS.length()).intValue();
            randCode += CHARACTERS.substring(idx, idx + 1);
        }
        return randCode;
    }
}