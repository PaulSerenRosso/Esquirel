using UnityEngine;

namespace Entities.FogOfWar {
    [CreateAssetMenu(menuName = "Remote Variables/FOV Manager")]
    public class FOVManagerSO : ScriptableObject {
        [Header("FOV Settings")]
        public FOVSettings SettingsFOV;
    }
}