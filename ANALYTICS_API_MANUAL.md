# Analytics API Manual for Frontend Team

This document describes the analytics endpoints available in **InventoryService** and **OrderService** for displaying metrics, trends, and statistics.

## Table of Contents

1. [InventoryService Analytics](#inventoryservice-analytics)
   - [Product Production Trend](#1-product-production-trend)
   - [Product Metrics](#2-product-metrics)
   - [Task Metrics](#3-task-metrics)
   - [Task Trend](#4-task-trend)
   - [All Tasks Metrics](#5-all-tasks-metrics)
2. [OrderService Analytics](#orderservice-analytics)
   - [Order Metrics (Pagination)](#1-order-metrics-with-pagination)
   - [Order Trend](#2-order-trend)
   - [Order Metrics (Date Range)](#3-order-metrics-by-date-range)
3. [TypeScript Interfaces](#typescript-interfaces)
4. [React Integration Examples](#react-integration-examples)
5. [Error Handling](#error-handling)

---

## InventoryService Analytics

Base URL: `http://localhost:5003` (or your InventoryService URL)

All endpoints require JWT authentication via Bearer token.

### 1. Product Production Trend

Get production trend data grouped by day, week, or month.

**Endpoint:** `GET /api/products/production-trend`

**Query Parameters:**
- `companyId` (Guid, required) - Company identifier
- `startDate` (DateTime, required) - Start date (ISO 8601 format)
- `endDate` (DateTime, required) - End date (ISO 8601 format)
- `period` (string, optional) - Grouping period: `"day"`, `"week"`, `"month"` (default: `"day"`)

**Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": [
    {
      "date": "2025-10-01T00:00:00Z",
      "value": 150.5,
      "label": "2025-10-01"
    },
    {
      "date": "2025-10-02T00:00:00Z",
      "value": 200.0,
      "label": "2025-10-02"
    }
  ],
  "errors": []
}
```

**Example Request:**
```javascript
const response = await fetch(
  `http://localhost:5003/api/products/production-trend?` +
  `companyId=123e4567-e89b-12d3-a456-426614174000&` +
  `startDate=2025-10-01T00:00:00Z&` +
  `endDate=2025-10-31T23:59:59Z&` +
  `period=day`,
  {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    }
  }
);
const data = await response.json();
```

**Use Case:** Display production volume over time in a line chart or bar chart.

---

### 2. Product Metrics

Get overall product metrics for a specific date range.

**Endpoint:** `GET /api/products/metrics`

**Query Parameters:**
- `companyId` (Guid, required) - Company identifier
- `startDate` (DateTime, required) - Start date
- `endDate` (DateTime, required) - End date

**Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "totalProducts": 250,
    "activeProducts": 230,
    "inactiveProducts": 20,
    "lowStockProducts": 15,
    "outOfStockProducts": 5,
    "totalProduced": 5000,
    "productionEfficiency": 95.5
  },
  "errors": []
}
```

**Field Descriptions:**
- `totalProducts` - Total number of products in the system
- `activeProducts` - Number of active products
- `inactiveProducts` - Number of inactive products
- `lowStockProducts` - Products with stock at or below minimum level
- `outOfStockProducts` - Products with zero stock
- `totalProduced` - Total quantity produced in the period
- `productionEfficiency` - Percentage (actual produced / planned) * 100

**Example Request:**
```javascript
const response = await fetch(
  `http://localhost:5003/api/products/metrics?` +
  `companyId=123e4567-e89b-12d3-a456-426614174000&` +
  `startDate=2025-10-01T00:00:00Z&` +
  `endDate=2025-10-31T23:59:59Z`,
  {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  }
);
const data = await response.json();
```

**Use Case:** Display KPI cards on a dashboard showing product statistics.

---

### 3. Task Metrics

Get production task metrics for a specific date range.

**Endpoint:** `GET /api/tasks/metrics`

**Query Parameters:**
- `companyId` (Guid, required) - Company identifier
- `startDate` (DateTime, required) - Start date
- `endDate` (DateTime, required) - End date

**Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "total": 150,
    "completed": 120,
    "inProgress": 20,
    "notStarted": 5,
    "cancelled": 5,
    "overdue": 10,
    "completionRate": 80.0,
    "averageCompletionTime": 4.5
  },
  "errors": []
}
```

**Field Descriptions:**
- `total` - Total number of tasks
- `completed` - Number of completed tasks
- `inProgress` - Number of tasks currently in progress
- `notStarted` - Number of tasks not yet started
- `cancelled` - Number of cancelled tasks
- `overdue` - Number of tasks past their planned end date
- `completionRate` - Percentage of completed tasks
- `averageCompletionTime` - Average hours to complete a task

**Example Request:**
```javascript
const response = await fetch(
  `http://localhost:5003/api/tasks/metrics?` +
  `companyId=123e4567-e89b-12d3-a456-426614174000&` +
  `startDate=2025-10-01T00:00:00Z&` +
  `endDate=2025-10-31T23:59:59Z`,
  {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  }
);
const data = await response.json();
```

**Use Case:** Display task completion statistics and efficiency metrics.

---

### 4. Task Trend

Get task creation trend data grouped by day, week, or month.

**Endpoint:** `GET /api/tasks/trend`

**Query Parameters:**
- `companyId` (Guid, required) - Company identifier
- `startDate` (DateTime, required) - Start date
- `endDate` (DateTime, required) - End date
- `period` (string, optional) - Grouping period: `"day"`, `"week"`, `"month"` (default: `"day"`)

**Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": [
    {
      "date": "2025-10-01T00:00:00Z",
      "value": 25,
      "label": "2025-10-01"
    },
    {
      "date": "2025-10-02T00:00:00Z",
      "value": 30,
      "label": "2025-10-02"
    }
  ],
  "errors": []
}
```

**Use Case:** Display task creation trends over time in a chart.

---

### 5. All Tasks Metrics

Get task metrics for all tasks with pagination (not limited by date range).

**Endpoint:** `GET /api/tasks`

**Query Parameters:**
- `companyId` (Guid, required) - Company identifier
- `skip` (int, optional) - Number of records to skip (default: 0)
- `take` (int, optional) - Number of records to take (default: 1000)

**Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "total": 500,
    "completed": 400,
    "inProgress": 80,
    "notStarted": 15,
    "cancelled": 5,
    "overdue": 20,
    "completionRate": 80.0,
    "averageCompletionTime": 5.2
  },
  "errors": []
}
```

**Use Case:** Display overall task statistics without date filtering.

---

## OrderService Analytics

Base URL: `http://localhost:5001` (or your OrderService URL)

All endpoints require JWT authentication via Bearer token.

### 1. Order Metrics (With Pagination)

Get order metrics with pagination support.

**Endpoint:** `GET /api/orders/metrics`

**Query Parameters:**
- `companyId` (Guid, required) - Company identifier
- `skip` (int, optional) - Number of records to skip (default: 0)
- `take` (int, optional) - Number of records to take (default: 1000)

**Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "total": 1000,
    "pending": 50,
    "confirmed": 200,
    "processing": 300,
    "completed": 400,
    "cancelled": 50,
    "totalRevenue": 125000.50,
    "averageOrderValue": 125.00,
    "totalItems": 5000
  },
  "errors": []
}
```

**Field Descriptions:**
- `total` - Total number of orders
- `pending` - Orders in Draft status
- `confirmed` - Orders in Confirmed status
- `processing` - Orders in InProduction or Ready status
- `completed` - Orders in Shipped or Completed status
- `cancelled` - Orders in Cancelled status
- `totalRevenue` - Sum of completed/shipped order amounts
- `averageOrderValue` - Average order amount
- `totalItems` - Total number of order items across all orders

**Example Request:**
```javascript
const response = await fetch(
  `http://localhost:5001/api/orders/metrics?` +
  `companyId=123e4567-e89b-12d3-a456-426614174000&` +
  `skip=0&take=1000`,
  {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  }
);
const data = await response.json();
```

**Use Case:** Display order statistics on a dashboard with large datasets using pagination.

---

### 2. Order Trend

Get order trend data grouped by day, week, or month.

**Endpoint:** `GET /api/orders/trend`

**Query Parameters:**
- `companyId` (Guid, required) - Company identifier
- `startDate` (DateTime, required) - Start date
- `endDate` (DateTime, required) - End date
- `period` (string, optional) - Grouping period: `"day"`, `"week"`, `"month"` (default: `"day"`)

**Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": [
    {
      "date": "2025-10-01T00:00:00Z",
      "value": 15000.50,
      "label": "2025-10-01"
    },
    {
      "date": "2025-10-02T00:00:00Z",
      "value": 18500.75,
      "label": "2025-10-02"
    }
  ],
  "errors": []
}
```

**Note:** The `value` field represents the total order amount (revenue) for that period.

**Example Request:**
```javascript
const response = await fetch(
  `http://localhost:5001/api/orders/trend?` +
  `companyId=123e4567-e89b-12d3-a456-426614174000&` +
  `startDate=2025-10-01T00:00:00Z&` +
  `endDate=2025-10-31T23:59:59Z&` +
  `period=week`,
  {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  }
);
const data = await response.json();
```

**Use Case:** Display revenue trends over time in a line or area chart.

---

### 3. Order Metrics (By Date Range)

Get order metrics for a specific date range.

**Endpoint:** `GET /api/orders/metrics/daterange`

**Query Parameters:**
- `companyId` (Guid, required) - Company identifier
- `startDate` (DateTime, required) - Start date
- `endDate` (DateTime, required) - End date

**Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "total": 250,
    "pending": 20,
    "confirmed": 50,
    "processing": 80,
    "completed": 90,
    "cancelled": 10,
    "totalRevenue": 45000.00,
    "averageOrderValue": 180.00,
    "totalItems": 1250
  },
  "errors": []
}
```

**Example Request:**
```javascript
const response = await fetch(
  `http://localhost:5001/api/orders/metrics/daterange?` +
  `companyId=123e4567-e89b-12d3-a456-426614174000&` +
  `startDate=2025-10-01T00:00:00Z&` +
  `endDate=2025-10-31T23:59:59Z`,
  {
    headers: {
      'Authorization': `Bearer ${token}`
    }
  }
);
const data = await response.json();
```

**Use Case:** Display order statistics filtered by a specific date range.

---

## TypeScript Interfaces

Here are the TypeScript interfaces for all DTOs:

```typescript
// Common Types
interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
  errors: string[];
}

interface TimeSeriesDataDto {
  date: string; // ISO 8601 date string
  value: number;
  label: string;
}

// InventoryService Types
interface ProductMetricsDto {
  totalProducts: number;
  activeProducts: number;
  inactiveProducts: number;
  lowStockProducts: number;
  outOfStockProducts: number;
  totalProduced: number;
  productionEfficiency: number;
}

interface TaskMetricsDto {
  total: number;
  completed: number;
  inProgress: number;
  notStarted: number;
  cancelled: number;
  overdue: number;
  completionRate: number;
  averageCompletionTime: number; // in hours
}

// OrderService Types
interface OrderMetricsDto {
  total: number;
  pending: number;
  confirmed: number;
  processing: number;
  completed: number;
  cancelled: number;
  totalRevenue: number;
  averageOrderValue: number;
  totalItems: number;
}

// Period type for trend endpoints
type PeriodType = 'day' | 'week' | 'month';
```

---

## React Integration Examples

### Example 1: Fetching Product Metrics

```tsx
import React, { useEffect, useState } from 'react';
import { useAuth } from './auth-context';

interface ProductMetrics {
  totalProducts: number;
  activeProducts: number;
  inactiveProducts: number;
  lowStockProducts: number;
  outOfStockProducts: number;
  totalProduced: number;
  productionEfficiency: number;
}

const ProductMetricsDashboard: React.FC = () => {
  const { token, companyId } = useAuth();
  const [metrics, setMetrics] = useState<ProductMetrics | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchMetrics = async () => {
      try {
        const startDate = new Date('2025-10-01').toISOString();
        const endDate = new Date('2025-10-31').toISOString();

        const response = await fetch(
          `http://localhost:5003/api/products/metrics?` +
          `companyId=${companyId}&` +
          `startDate=${startDate}&` +
          `endDate=${endDate}`,
          {
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json'
            }
          }
        );

        if (!response.ok) {
          throw new Error('Failed to fetch metrics');
        }

        const result = await response.json();

        if (result.success) {
          setMetrics(result.data);
        } else {
          setError(result.message);
        }
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error');
      } finally {
        setLoading(false);
      }
    };

    fetchMetrics();
  }, [token, companyId]);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!metrics) return <div>No data available</div>;

  return (
    <div className="metrics-dashboard">
      <div className="metric-card">
        <h3>Total Products</h3>
        <p>{metrics.totalProducts}</p>
      </div>
      <div className="metric-card">
        <h3>Active Products</h3>
        <p>{metrics.activeProducts}</p>
      </div>
      <div className="metric-card">
        <h3>Low Stock</h3>
        <p className="warning">{metrics.lowStockProducts}</p>
      </div>
      <div className="metric-card">
        <h3>Production Efficiency</h3>
        <p>{metrics.productionEfficiency.toFixed(2)}%</p>
      </div>
    </div>
  );
};

export default ProductMetricsDashboard;
```

---

### Example 2: Displaying Order Trend Chart

```tsx
import React, { useEffect, useState } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend } from 'recharts';
import { useAuth } from './auth-context';

interface TrendData {
  date: string;
  value: number;
  label: string;
}

const OrderTrendChart: React.FC = () => {
  const { token, companyId } = useAuth();
  const [trendData, setTrendData] = useState<TrendData[]>([]);
  const [period, setPeriod] = useState<'day' | 'week' | 'month'>('day');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchTrend = async () => {
      setLoading(true);
      try {
        const endDate = new Date();
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - 30); // Last 30 days

        const response = await fetch(
          `http://localhost:5001/api/orders/trend?` +
          `companyId=${companyId}&` +
          `startDate=${startDate.toISOString()}&` +
          `endDate=${endDate.toISOString()}&` +
          `period=${period}`,
          {
            headers: {
              'Authorization': `Bearer ${token}`
            }
          }
        );

        const result = await response.json();

        if (result.success) {
          setTrendData(result.data);
        }
      } catch (err) {
        console.error('Error fetching trend:', err);
      } finally {
        setLoading(false);
      }
    };

    fetchTrend();
  }, [token, companyId, period]);

  if (loading) return <div>Loading chart...</div>;

  return (
    <div>
      <div className="period-selector">
        <button onClick={() => setPeriod('day')} className={period === 'day' ? 'active' : ''}>
          Day
        </button>
        <button onClick={() => setPeriod('week')} className={period === 'week' ? 'active' : ''}>
          Week
        </button>
        <button onClick={() => setPeriod('month')} className={period === 'month' ? 'active' : ''}>
          Month
        </button>
      </div>

      <LineChart width={800} height={400} data={trendData}>
        <CartesianGrid strokeDasharray="3 3" />
        <XAxis dataKey="label" />
        <YAxis />
        <Tooltip formatter={(value) => `$${value.toFixed(2)}`} />
        <Legend />
        <Line
          type="monotone"
          dataKey="value"
          stroke="#8884d8"
          name="Revenue"
        />
      </LineChart>
    </div>
  );
};

export default OrderTrendChart;
```

---

### Example 3: Custom Hook for Analytics

```typescript
// useAnalytics.ts
import { useState, useEffect, useCallback } from 'react';

interface UseAnalyticsOptions {
  token: string;
  companyId: string;
  baseUrl: string;
}

export function useProductMetrics(
  options: UseAnalyticsOptions,
  startDate: string,
  endDate: string
) {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchMetrics = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(
        `${options.baseUrl}/api/products/metrics?` +
        `companyId=${options.companyId}&` +
        `startDate=${startDate}&` +
        `endDate=${endDate}`,
        {
          headers: {
            'Authorization': `Bearer ${options.token}`
          }
        }
      );

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const result = await response.json();

      if (result.success) {
        setData(result.data);
      } else {
        setError(result.message || 'Failed to fetch metrics');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  }, [options, startDate, endDate]);

  useEffect(() => {
    fetchMetrics();
  }, [fetchMetrics]);

  return { data, loading, error, refetch: fetchMetrics };
}

// Usage:
// const { data, loading, error } = useProductMetrics(
//   { token, companyId, baseUrl: 'http://localhost:5003' },
//   '2025-10-01T00:00:00Z',
//   '2025-10-31T23:59:59Z'
// );
```

---

## Error Handling

All endpoints return a consistent error structure:

```json
{
  "success": false,
  "message": "Error description",
  "data": null,
  "errors": [
    "Detailed error message 1",
    "Detailed error message 2"
  ]
}
```

### Common HTTP Status Codes

- `200 OK` - Request successful
- `400 Bad Request` - Invalid parameters
- `401 Unauthorized` - Missing or invalid token
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

### Error Handling Example

```typescript
async function fetchAnalytics(url: string, token: string) {
  try {
    const response = await fetch(url, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });

    if (!response.ok) {
      // Handle HTTP errors
      if (response.status === 401) {
        throw new Error('Unauthorized. Please log in again.');
      }
      if (response.status === 403) {
        throw new Error('You do not have permission to access this resource.');
      }
      if (response.status === 500) {
        throw new Error('Server error. Please try again later.');
      }
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const result = await response.json();

    if (!result.success) {
      // Handle application-level errors
      const errorMessage = result.errors?.join(', ') || result.message;
      throw new Error(errorMessage);
    }

    return result.data;
  } catch (err) {
    console.error('Error fetching analytics:', err);
    throw err;
  }
}
```

---

## Best Practices

1. **Date Formatting**: Always use ISO 8601 format for dates (`YYYY-MM-DDTHH:mm:ssZ`)
2. **Token Management**: Store JWT tokens securely and refresh them before expiration
3. **Error Handling**: Always check both HTTP status codes and the `success` field
4. **Loading States**: Show loading indicators while fetching data
5. **Caching**: Consider caching analytics data for a short period to reduce API calls
6. **Date Ranges**: Use reasonable date ranges to avoid performance issues
7. **Pagination**: Use the pagination parameters for large datasets
8. **Period Selection**: Allow users to switch between day/week/month views for trend data

---

## Support

For questions or issues:
- Check the Swagger documentation at `http://localhost:5003/swagger` (InventoryService) or `http://localhost:5001/swagger` (OrderService)
- Contact the backend team
- Review error logs in browser console

---

**Document Version:** 1.0
**Last Updated:** October 14, 2025
**Generated for:** CloudShopMgr Analytics Endpoints
