using UnityEngine;

namespace Entities.Capacities
{
    public class ActiveHealPotion : ActiveCapacity
    {
        private ActiveHealPotionSO so;
        private IActiveLifeable lifeable;

        public override bool TryCast( int[] targets, Vector3[] position)
        {
            so = (ActiveHealPotionSO)AssociatedActiveCapacitySO();
            
            lifeable = caster.GetComponent<IActiveLifeable>();
            
            lifeable.IncreaseCurrentHpRPC(so.healAmount);
            
            return true;
        }

        public override void PlayFeedback( int[] targets, Vector3[] position)
        {
            
      //      so = (ActiveHealPotionSO)AssociatedActiveCapacitySO();
        //    instantiateFeedbackObj = PoolLocalManager.Instance.PoolInstantiate(so.feedbackPrefab, caster.transform.position, Quaternion.identity,
          //      caster.transform);
            
     
        }

     
        public override void CancelCapacity()
        {
            throw new System.NotImplementedException();
        }

       
    
    }
}

