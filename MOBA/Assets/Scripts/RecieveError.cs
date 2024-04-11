using Photon.Realtime;
using UnityEngine;

public class RecieveError : MonoBehaviour, IErrorInfoCallback {
    public void OnErrorInfo(ErrorInfo errorInfo) {
        Debug.LogWarning(errorInfo.Info);
    }
}
