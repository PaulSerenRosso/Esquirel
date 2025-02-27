using Entities.Capacities;
using UnityEngine;


public  class ActiveAttackCapacityPrevizualisable : MonoBehaviour
{
    [SerializeField] protected GameObject previsualisation;

    public virtual void UpdatePrevisualisation(
        ActiveAttackWithColliderWithPrevisualisableCapacity
            activeAttackCapacity)
    {
        transform.position += activeAttackCapacity.champion.rotateParent.forward*activeAttackCapacity.so.offsetAttack;
    }
    
}