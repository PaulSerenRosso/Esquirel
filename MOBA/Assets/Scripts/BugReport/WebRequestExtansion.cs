using UnityEngine;
using UnityEngine.Networking;

public static class WebRequestExtansion {
    /// <summary>
    /// Post a web request using a form and a link
    /// </summary>
    /// <param name="form"></param>
    /// <param name="url"></param>
    /// <returns></returns>
    public static UnityWebRequest PostWebRequest(this WWWForm form, string url) {
        UnityWebRequest uwr = UnityWebRequest.Post(url, form);
        UnityWebRequestAsyncOperation operation = uwr.SendWebRequest();
        return uwr;
    }
}
