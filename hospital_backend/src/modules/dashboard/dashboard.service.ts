import { HOSPITAL_ROLES, type HospitalRole } from '../../constants/roles';
import { prisma } from '../../prisma';
import { AppError } from '../../utils/error';

export interface DashboardOptionDto {
  id: number;
  title: string;
  description: string;
  icon: string;
  routeName: string;
  queryParams: Record<string, unknown> | null;
}

function mapOption(option: { id: number; title: string; description: string; icon: string; routeName: string; queryParams: unknown }) {
  return {
    id: option.id,
    title: option.title,
    description: option.description,
    icon: option.icon,
    routeName: option.routeName,
    queryParams: option.queryParams as Record<string, unknown> | null,
  };
}

export async function getDashboardOptionsForRole(roleName: HospitalRole): Promise<DashboardOptionDto[]> {
  if (!HOSPITAL_ROLES.includes(roleName)) {
    throw new AppError(400, `Unsupported role: ${roleName}`);
  }

  const role = await prisma.role.findUnique({
    where: { name: roleName },
    include: { dashboardOptions: true },
  });

  if (!role) {
    throw new AppError(404, 'Role not found');
  }

  return role.dashboardOptions.map(mapOption);
}

export async function getDashboardOptionsForUser(userId: number): Promise<DashboardOptionDto[]> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    include: {
      role: {
        include: {
          dashboardOptions: true,
        },
      },
    },
  });

  if (!user || !user.role) {
    throw new AppError(404, 'User or role not found');
  }

  return user.role.dashboardOptions.map(mapOption);
}
