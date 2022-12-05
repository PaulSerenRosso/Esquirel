using System;
using Entities.Capacities;
using UnityEngine;

[CreateAssetMenu(menuName = "Capacity/ActiveCapacitySO/Auto Attack", fileName = "AutoAttackSO")]
public class ActiveAutoAttackSO : ActiveCapacitySO
{
    public float maxRange;
    public float animationTime;

    public float damageBeginTime;
    public float damageTime;

    public GameObject damagePrefab;



    // contrainte technique : le temps de cooldonw doit etre plus faible que le temps de de dégat infliger 
    // le fx timer à la normal
    // le collider timer revient à la normal 
  
    public float damage;

    
    public override Type AssociatedType()
    {
        return typeof(ActiveAutoAttack);
    }
}
