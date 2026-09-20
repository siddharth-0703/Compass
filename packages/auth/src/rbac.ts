import { Role } from '@rural/types';

export const ROLE_PERMISSIONS: Record<Role, string[]> = {
  entrepreneur: ['read:own_profile', 'update:own_profile', 'read:marketplace', 'read:schemes'],
  mentor: ['read:own_profile', 'update:own_profile', 'read:marketplace', 'read:schemes', 'mentor:read', 'mentor:update', 'mentor:approve'],
  admin: ['read:any_profile', 'update:any_profile', 'admin:access_dashboard', 'admin:moderate_content'],
  investor: ['read:own_profile', 'read:marketplace', 'read:schemes', 'investor:connect'],
  ngo: ['read:own_profile', 'read:marketplace', 'read:schemes'],
  government: ['read:own_profile', 'read:analytics']
};

export const hasPermission = (roles: Role[], requiredPermission: string): boolean => {
  for (const role of roles) {
    const perms = ROLE_PERMISSIONS[role];
    if (perms && perms.includes(requiredPermission)) {
      return true;
    }
  }
  return false;
};
