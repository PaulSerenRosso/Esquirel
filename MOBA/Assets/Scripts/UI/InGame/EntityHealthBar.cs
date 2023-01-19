using System.Collections.Generic;
using Entities;
using UnityEngine;
using UnityEngine.UI;

namespace UIComponents
{
    public class EntityHealthBar : MonoBehaviour
    {
        [SerializeField] private Image healthBar;
        [SerializeField] private List<Image> healthImageList = new List<Image>();
        private IActiveLifeable lifeable;

        public void InitHealthBar(Entity entity)
        {
            lifeable = (IActiveLifeable)entity;
            
            UIManager.Instance.LookAtCamera(this.transform);
            healthBar.fillAmount = lifeable.GetCurrentHpPercent();
            
            lifeable.OnSetCurrentHpFeedback += UpdateFillPercent;
            lifeable.OnSetCurrentHpPercentFeedback += UpdateFillPercentByPercent;
            lifeable.OnIncreaseCurrentHpFeedback += UpdateFillPercent;
            lifeable.OnDecreaseCurrentHpFeedback += UpdateFillPercent;
            lifeable.OnIncreaseMaxHpFeedback += UpdateFillPercent;
            lifeable.OnDecreaseMaxHpFeedback += UpdateFillPercent;

            UpdateFillPercentByPercent(0);

        }
        
        private void UpdateFillPercentByPercent(float value) {
            for (int i = 0; i < healthImageList.Count; i++) {
                healthImageList[i].fillAmount = i < lifeable.GetCurrentHp() ? 1 : 0;
                healthImageList[i].gameObject.SetActive(!(i >= lifeable.GetMaxHp()));
            }
            //healthBar.fillAmount = lifeable.GetCurrentHp()/lifeable.GetMaxHp();
        }
    
        private void UpdateFillPercent(float value)
        {
            
            for (int i = 0; i < healthImageList.Count; i++) {
                healthImageList[i].fillAmount = i < lifeable.GetCurrentHp() ? 1 : 0;
                healthImageList[i].gameObject.SetActive(!(i >= lifeable.GetMaxHp()));
            }
            //healthBar.fillAmount = lifeable.GetCurrentHp()/lifeable.GetMaxHp();
        }
        
    }
}