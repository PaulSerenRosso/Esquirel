using System.Collections.Generic;
using Entities;
using ExitGames.Client.Photon.StructWrapping;
using GameStates;
using UnityEngine;
using UnityEngine.UI;

namespace UIComponents
{
    public class EntityHealthBar : MonoBehaviour {
        [SerializeField] private DamagePopUp playerPopUp = null;
        [SerializeField] private Image healthBar;
        [SerializeField] private List<Image> healthImageList = new List<Image>();
        [SerializeField] private List<Animator> healthAnimatorList = new List<Animator>();
        
        private IActiveLifeable lifeable;
        private Entity currentEntity;

        public void InitHealthBar(Entity entity) {
            this.currentEntity = entity;
            lifeable = (IActiveLifeable)currentEntity;
            
            UIManager.Instance.LookAtCamera(this.transform);
            healthBar.fillAmount = lifeable.GetCurrentHpPercent();
            
            lifeable.OnSetCurrentHpFeedback += UpdateFillPercent;
            lifeable.OnSetCurrentHpPercentFeedback += UpdateFillPercentByPercent;
            lifeable.OnIncreaseCurrentHpFeedback += UpdateFillPercent;
            lifeable.OnDecreaseCurrentHpFeedback += UpdateFillPercent;
            lifeable.OnIncreaseMaxHpFeedback += UpdateFillPercent;
            lifeable.OnDecreaseMaxHpFeedback += UpdateFillPercent;

            UpdateFillPercentByPercent(0);
            for (int i = 0; i <  healthImageList.Count; i++)
            {
                healthImageList[i].color = GameStateMachine.Instance.GetTeamColor(entity.team);
            }

        }
        
        private void UpdateFillPercentByPercent(float value) {
            for (int i = 0; i < healthImageList.Count; i++) {
                healthImageList[i].fillAmount = i < lifeable.GetCurrentHp() ? 1 : 0;
                healthAnimatorList[i].gameObject.SetActive(!(i >= lifeable.GetMaxHp()));
                
            }
            //healthBar.fillAmount = lifeable.GetCurrentHp()/lifeable.GetMaxHp();
        }
    
        private void UpdateFillPercent(float value)
        {
            int lastHp = 0;
            for (int i = 0; i < healthImageList.Count; i++) {
                lastHp += (healthImageList[i].fillAmount != 0 ? 1 : 0);
                if(i >= lifeable.GetCurrentHp() && healthImageList[i].fillAmount != 0) healthAnimatorList[i].SetTrigger("RemoveLife");
                healthImageList[i].fillAmount = i < lifeable.GetCurrentHp() ? 1 : 0;
                healthAnimatorList[i].gameObject.SetActive(!(i >= lifeable.GetMaxHp()));
            }
            
            if(lifeable.GetCurrentHp() - lastHp < 0) currentEntity.gameObject.GetComponent<DamagePopUp>().CreateDamagePopUp((int)lifeable.GetCurrentHp() - lastHp, lifeable.GetCurrentHp() <= 0);
            //healthBar.fillAmount = lifeable.GetCurrentHp()/lifeable.GetMaxHp();
        }
        
    }
}