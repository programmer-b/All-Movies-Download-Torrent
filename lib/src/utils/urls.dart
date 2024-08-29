const base = 'https://www.downloader.movie';
// const base = 'http://192.168.0.101:3000';

String category(String type, String current, int page) =>
    '$base/$type/$current/page/$page';

String browse(String type, String current, String slug, int page) =>
    '$base/$type/$current/$slug/page/$page';
const String search = '$base/search';

const auth = '$base/api/v6/auth';

const deleteUser = '$auth/delete';
const resendOTPUrl = '$auth/resend-otp';
const verifyUrl = '$auth/verify';
const setNewPasswordUrl = '$auth/set-new-password';
const forgotPasswordUrl = '$auth/forgot-password';
const loginUrl = '$auth/login';
const registerUrl = '$auth/register';

const favoritesUrl = '$base/api/v6/favorites';

const addFavoriteUrl = '$favoritesUrl/add';
const removeFavoriteUrl = '$favoritesUrl/remove';
const getFavoritesUrl = '$favoritesUrl/get';
const favoriteExistsUrl = '$favoritesUrl/exists';

String detailsUrl(id) => '$base/details/$id';

const downloadUrl = '$base/download';

const reportUrl = '$base/api/v6/reports';

const acceptContentRemovalUrl = '$reportUrl/accept';
const rejectContentRemovalUrl = '$reportUrl/reject';
const removeContentUrl = '$reportUrl/remove';

const forumsUrl = '$base/api/v6/forums';

const talks = '$forumsUrl/talks';
const talk = '$forumsUrl/talk';
const reply = '$forumsUrl/reply';
const like = '$forumsUrl/like';
const dislike = '$forumsUrl/dislike';
const deleteTalk = '$forumsUrl/deleteTalk';

const contactUrl = '$base/api/v6/contact';

const configsUrl = '$base/api/v6/configs';