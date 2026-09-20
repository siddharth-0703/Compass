export const Operators: Record<string, (profileValue: any, ruleValue: any) => boolean> = {
  EQ: (profileValue: any, ruleValue: any) => profileValue === ruleValue,
  NEQ: (profileValue: any, ruleValue: any) => profileValue !== ruleValue,
  GT: (profileValue: any, ruleValue: any) => Number(profileValue) > Number(ruleValue),
  GTE: (profileValue: any, ruleValue: any) => Number(profileValue) >= Number(ruleValue),
  LT: (profileValue: any, ruleValue: any) => Number(profileValue) < Number(ruleValue),
  LTE: (profileValue: any, ruleValue: any) => Number(profileValue) <= Number(ruleValue),
  IN: (profileValue: any, ruleValue: any[]) => Array.isArray(ruleValue) && ruleValue.includes(profileValue),
  NOT_IN: (profileValue: any, ruleValue: any[]) => Array.isArray(ruleValue) && !ruleValue.includes(profileValue),
  BETWEEN: (profileValue: any, ruleValue: [number, number]) => {
    const val = Number(profileValue);
    return Array.isArray(ruleValue) && ruleValue.length === 2 && val >= ruleValue[0] && val <= ruleValue[1];
  },
  CONTAINS: (profileValue: any[], ruleValue: any) => Array.isArray(profileValue) && profileValue.includes(ruleValue),
  EXISTS: (profileValue: any, ruleValue: boolean) => {
    const exists = profileValue !== undefined && profileValue !== null;
    return ruleValue ? exists : !exists;
  }
};
