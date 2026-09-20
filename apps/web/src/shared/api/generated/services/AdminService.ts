/* generated using openapi-typescript-codegen -- do not edit */
/* istanbul ignore file */
/* tslint:disable */
/* eslint-disable */
import type { SuccessResponse } from '../models/SuccessResponse';
import type { CancelablePromise } from '../core/CancelablePromise';
import type { BaseHttpRequest } from '../core/BaseHttpRequest';
export class AdminService {
    constructor(public readonly httpRequest: BaseHttpRequest) {}
    /**
     * Retrieve a paginated list of users
     * @param page Page number
     * @param pageSize Number of items per page
     * @param search Search term (phone or email)
     * @param sortBy Field to sort by
     * @param sortOrder Sort order
     * @param role Filter by user role
     * @returns SuccessResponse A paginated list of users
     * @throws ApiError
     */
    public getAdminUsers(
        page: number = 1,
        pageSize: number = 20,
        search?: string,
        sortBy?: string,
        sortOrder?: 'asc' | 'desc',
        role?: string,
    ): CancelablePromise<SuccessResponse> {
        return this.httpRequest.request({
            method: 'GET',
            url: '/admin/users',
            query: {
                'page': page,
                'pageSize': pageSize,
                'search': search,
                'sortBy': sortBy,
                'sortOrder': sortOrder,
                'role': role,
            },
            errors: {
                401: `Unauthorized`,
                403: `Forbidden (Not an admin)`,
            },
        });
    }
    /**
     * Retrieve a paginated list of businesses
     * @param page
     * @param pageSize
     * @param search
     * @param sortBy
     * @param sortOrder
     * @param status
     * @param category
     * @returns SuccessResponse A paginated list of businesses
     * @throws ApiError
     */
    public getAdminBusinesses(
        page: number = 1,
        pageSize: number = 20,
        search?: string,
        sortBy?: string,
        sortOrder?: 'asc' | 'desc',
        status?: string,
        category?: string,
    ): CancelablePromise<SuccessResponse> {
        return this.httpRequest.request({
            method: 'GET',
            url: '/admin/businesses',
            query: {
                'page': page,
                'pageSize': pageSize,
                'search': search,
                'sortBy': sortBy,
                'sortOrder': sortOrder,
                'status': status,
                'category': category,
            },
            errors: {
                401: `Unauthorized`,
                403: `Forbidden (Not an admin)`,
            },
        });
    }
}
