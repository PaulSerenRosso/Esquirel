using System;
using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;

namespace Entities.Capacities
{
public abstract class ActiveAttackCapacitySO : ActiveCapacitySO
{
    public ActiveCapacityAnimationLauncherInfo activeCapacityAnimationLauncherInfo;
    public float damageBeginTime;
    public float damageTime;
    public float damage;
    public ActiveAttackCapacityCollider damagePrefab;
    public float offsetAttack; 



}
}
